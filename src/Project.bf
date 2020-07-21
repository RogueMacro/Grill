using System;
using System.Collections;
using JetFistGames.Toml;

namespace Grill
{
	[Reflect]
	public class Project
	{
		[NotDataMember]
		public String Name => (String) Project["Name"];

		public int FileVersion;

		public Dictionary<String, Object> Project ~ DeleteDictionaryAndKeysAndItems!(_);
		public Dictionary<String, Object> Dependencies ~ DeleteDictionaryAndKeysAndItems!(_);
	}
}
