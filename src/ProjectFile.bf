using System;
using System.Collections;
using JetFistGames.Toml;

namespace Grill
{
	[Reflect]
	public class ProjectFile
	{
		public int FileVersion;

		public Project Project ~ delete _;
		public Dictionary<String, Object> Dependencies ~ DeleteDictionaryAndKeysAndItems!(_);
	}
}
