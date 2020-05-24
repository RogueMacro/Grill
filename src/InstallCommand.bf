using System;

namespace bpm
{
	[Reflect, AlwaysInclude(AssumeInstantiated=true, IncludeAllMethods=true)]
	public class InstallCommand : ICommand
	{
		public void Execute(String package, bool global)
		{
			Console.WriteLine("Installing {}, Global={}", package, global);
		}
	}
}
