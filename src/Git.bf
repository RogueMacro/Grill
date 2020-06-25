using Grill.CLI;
using System;
using System.IO;
using System.Diagnostics;
using Grill.Utility;

namespace Grill
{
	public static class Git
	{
		public static String GitPath = new String();
		public static String ExePath = new String();

		public static this()
		{
			Path.InternalCombine(GitPath, SpecialFolder.SourceDirectory, "Git");
			Path.InternalCombine(ExePath, GitPath, "bin/git.exe");
		}

		public static Result<void> Clone(String url, String to)
		{
			return Execute("-c", "http.sslVerify=false", "clone", url, to);
		}

		private static Result<void> Execute(params StringView[] args)
		{
			var command = scope String()..AppendF("\"\"{}\" ", ExePath);

			for (var arg in args)
			{
				if ((arg.Length >= 2 && arg[0].IsLetter && arg[1] == ':' && (arg[2] == '/' || arg[2] == '\\')) ||
					arg.StartsWith('/') ||
					arg.StartsWith('\\') ||
					arg.StartsWith('.')) 
					command.AppendF("\"{}\" ", arg);
				else
					command.AppendF("{} ", arg);
			}

			if (CLI.CurrentVerbosity != .Verbose)
				command.Append("> /dev/null 2>&1");

			command.Append('"');

			return Cpp.system(command) == 0 ? .Ok : .Err;
		}

		public static ~this()
		{
			delete GitPath;
			delete ExePath;
		}
	}
}
