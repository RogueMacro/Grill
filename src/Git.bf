using System;
using System.IO;
using System.Diagnostics;

namespace Grill
{
	public static class Git
	{
		public static String LocalExePath = "Git/bin/git.exe";
		public static void GetFullExePath(String target) => Path.InternalCombine(target, SpecialFolder.SourceDirectory, LocalExePath);

		public static Result<void> Clone(String url, String to)
		{
			return Execute("clone", url, to);
		}

		private static Result<void> Execute(params StringView[] args)
		{
			var exe = scope String();
			GetFullExePath(exe);
			var command = scope String()..AppendF("\"\"{}\" ", exe);

			for (int i = 0; i < args.Count; ++i)
				command.AppendF("\"{}\" ", args[i]);

			if (!Program.IsDebug)
				command.Append("> /dev/null 2>&1");

			command.Append('"');

			return Cpp.system(command) == 0 ? .Ok : .Err;
		}
	}
}
