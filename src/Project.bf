using System;
using System.Collections;

namespace Grill
{
	[Reflect]
	public class Project
	{
		public String Name ~ delete _;
		public Dictionary<String, Object> Project ~ DeleteDictionaryAndKeysAndItems!(_);
		public Dictionary<String, Object> Dependencies ~ DeleteDictionaryAndKeysAndItems!(_);
	}
}
