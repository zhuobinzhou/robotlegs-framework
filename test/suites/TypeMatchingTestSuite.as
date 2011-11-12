//------------------------------------------------------------------------------
//  Copyright (c) 2011 the original author or authors. All Rights Reserved. 
// 
//  NOTICE: You are permitted to use, modify, and distribute this file 
//  in accordance with the terms of the license agreement accompanying it. 
//------------------------------------------------------------------------------

package suites
{
	import org.robotlegs.v2.core.impl.TypeFilterTest;
	import org.robotlegs.v2.core.impl.TypeFilterUsageTest;
	import org.robotlegs.v2.core.impl.TypeMatcherTest;
	import org.robotlegs.v2.core.impl.PackageFilter_descriptorTest;
	import org.robotlegs.v2.core.impl.PackageMatchingTest;

	[RunWith("org.flexunit.runners.Suite")]
	[Suite]
	public class TypeMatchingTestSuite
	{

		public var typeFilterTest:TypeFilterTest;

		public var typeFilterUsageTest:TypeFilterUsageTest;

		public var typeMatcherTest:TypeMatcherTest;
		
		public var packageMatcherTest:PackageMatchingTest;
		
		public var packageFilter_descriptorTest:PackageFilter_descriptorTest;
	}
}