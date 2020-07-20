using System;
using System.IO;
using System.Collections;
using JetFistGames.Toml;
using CowieCLI;
using Grill.Utility;

namespace Grill
{
	[DataContract]
	public class Config
	{
		public static Config Instance = null ~ Delete!(_);

		[DataMember("Overrides")]
		private Dictionary<String, PackageOverride> mPackageOverrides = null ~ DeleteDictionaryAndKeysAndItems!(_);

		public static void Load()
		{
			if (!File.Exists(GrillPath.ConfigPath))
				File.WriteAllText(GrillPath.ConfigPath, "");

			var config = new Config();
			var result = TomlSerializer.ReadFile(GrillPath.ConfigPath, config);
			if (result case .Err(let err))
				CowieCLI.Error("Could not load config file: {}", err);

			Instance = config;
		}

		public class PackageOverride
		{
			public String DefaultNamespace ~ delete _;
		}
	}
}
