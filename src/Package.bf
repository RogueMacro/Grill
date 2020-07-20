using CowieCLI;
using System;
using System.Collections;

namespace Grill
{
	[Reflect]
	public class Package
	{
		public String Name ~ delete _;
		public String Version ~ delete _;

		public Dictionary<String, Object> Dependencies ~ DeleteDictionaryAndKeysAndItems!(_);
	}
}
