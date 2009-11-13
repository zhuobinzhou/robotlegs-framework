/*
 * Copyright (c) 2009 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.robotlegs.base
{
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	import org.robotlegs.core.IInjector;
	import org.robotlegs.core.IReflector;
	import org.robotlegs.core.IViewMap;
	
	/**
	 * An abstract <code>IViewMap</code> implementation
	 */
	public class ViewMap implements IViewMap
	{
		protected var _enabled:Boolean = true;
		protected var _contextView:DisplayObjectContainer;
		
		protected var injector:IInjector;
		protected var reflector:IReflector;
		protected var useCapture:Boolean;
		
		protected var mappedPackages:Array;
		protected var mappedTypes:Dictionary;
		
		protected var injectedViews:Dictionary;
		
		//---------------------------------------------------------------------
		// Constructor
		//---------------------------------------------------------------------
		
		/**
		 * Creates a new <code>ViewMap</code> object
		 *
		 * @param contextView The root view node of the context. The map will listen for ADDED_TO_STAGE events on this node
		 * @param injector An <code>IInjector</code> to use for this context
		 * @param reflector An <code>IReflector</code> to use for this context
		 */
		public function ViewMap(contextView:DisplayObjectContainer, injector:IInjector, reflector:IReflector)
		{
			this.injector = injector;
			this.reflector = reflector;
			
			// mappings - if you can do it with fewer dictionaries you get a prize
			this.mappedPackages = new Array();
			this.mappedTypes = new Dictionary(false);
			this.injectedViews = new Dictionary(true);
			
			// change this at your peril lest ye understand the problem and have a better solution
			this.useCapture = true;
			
			// this must come last, see the setter
			this.contextView = contextView;
		}
		
		//---------------------------------------------------------------------
		// API
		//---------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		public function mapPackage(packageName:String):void
		{
			if (mappedPackages.indexOf(packageName) == -1)
			{
				mappedPackages.push(packageName);
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function unmapPackage(packageName:String):void
		{
			var index:int = mappedPackages.indexOf(packageName);
			if (index > -1)
			{
				mappedPackages.splice(index, 1);
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function mapType(type:Class):void
		{
			if (mappedTypes[type])
			{
				return;
			}
			
			mappedTypes[type] = type;
			
			if (contextView && (contextView is type))
			{
				injectInto(contextView);
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function unmapType(type:Class):void
		{
			delete mappedTypes[type];
		}
		
		/**
		 * @inheritDoc
		 */
		public function hasType(type:Class):Boolean
		{
			return (mappedTypes[type] != null);
		}
				
		/**
		 * @inheritDoc
		 */
		public function hasPackage(packageName:String):Boolean
		{
			return mappedPackages.indexOf(packageName) > -1;
		}
		
		/**
		 * @inheritDoc
		 */
		public function get contextView():DisplayObjectContainer
		{
			return _contextView;
		}
		
		/**
		 * @inheritDoc
		 */
		public function set contextView(value:DisplayObjectContainer):void
		{
			if (value != _contextView)
			{
				removeListeners();
				_contextView = value;
				addListeners();
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function get enabled():Boolean
		{
			return _enabled;
		}
		
		/**
		 * @inheritDoc
		 */
		public function set enabled(value:Boolean):void
		{
			if (value != _enabled)
			{
				removeListeners();
				_enabled = value;
				addListeners();
			}
		}
		
		//---------------------------------------------------------------------
		// Internal
		//---------------------------------------------------------------------
		
		/**
		 * @private
		 */
		protected function addListeners():void
		{
			if (contextView && enabled)
			{
				contextView.addEventListener(Event.ADDED_TO_STAGE, onViewAdded, useCapture, 0, true);
			}
		}
		
		/**
		 * @private
		 */
		protected function removeListeners():void
		{
			if (contextView && enabled)
			{
				contextView.removeEventListener(Event.ADDED_TO_STAGE, onViewAdded, useCapture);
			}
		}
		
		/**
		 * @private
		 */
		protected function onViewAdded(e:Event):void
		{
			if (injectedViews[e.target])
			{
				return;
			}
			
			for each (var type:Class in mappedTypes)
			{
				if (e.target is type)
				{
					injectInto(e.target);
					return;
				}
			}
			
			var len:int = mappedPackages.length;
			if (len > 0)
			{
				var className:String = reflector.getFQCN(e.target);
				for (var i:int = 0; i < len; i++)
				{
					var packageName:String = mappedPackages[i];
					if (packageName == className.substr(0, packageName.length))
					{
						injectInto(e.target);
						return;
					}
				}
			}
		}
		
		protected function injectInto(target:*):void
		{
			injector.injectInto(target);
			injectedViews[target] = true;
		}
	}
}
