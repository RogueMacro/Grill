using bpm.Networking;
using System;

namespace bpm.Commands
{
	[Reflect, AlwaysInclude(AssumeInstantiated=true, IncludeAllMethods=true)]
	public class InstallCommand : ICommand
	{
		public void Execute(StringView package, bool global)
		{
			Console.WriteLine("Installing {}, Global={}", package, global);

			let result = Github.Clone("None");
			Console.WriteLine("Cloning resulted with: {}", result);
		}
	}
}
