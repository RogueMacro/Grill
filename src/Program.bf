using Grill.CLI;
using Grill.Commands;
using System;
using System.Collections;
using System.Reflection;
using System.Net;
using System.IO;

namespace Grill
{
	public static class Program
	{
		static void Main(String[] args)
		{
			/*Console.WriteLine(Test());

			String Test()
			{
				return scope String();
			}

			return;*/
			CLI.RegisterCommand<InstallCommand>("install");
			CLI.RegisterCommand<AddCommand>("add");

			CLI.Run(args);

#if DEBUG
			Console.Read();
#endif
		}
	}
}
