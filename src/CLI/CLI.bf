using Grill.Utility;
using System;
using System.Collections;
using System.Reflection;

namespace Grill.CLI
{
	public static class CLI
	{
		public static List<CommandEntry> Commands = new .() ~ DeleteContainerAndItems!(_);

		public static Verbosity CurrentVerbosity = .Normal;

		private static void Help(ICommand command = null)
		{
			if (command == null)
			{
				Console.WriteLine(
					"""
					Beef Package Manager
					
					USAGE:
					    grill <command> [options]
					
					OPTIONS:
					    -V, --version   Show the current version of Grill
					    -v, --verbose   Use verbose output
					        --list      List all commands
					    -q, --quiet     Disable output
					""");
			}
			else
			{
				Console.WriteLine(command.Info.About);
			}
		}

		public static void Run(Span<String> args)
		{
			List<CommandCall> calls = scope .();
			CommandCall commandCall = scope .();
			List<StringView> extraCommands = null;

			for (var arg in args)
			{
				// Option
				if (arg.StartsWith('-')) 
				{
					commandCall.Options.Add(arg);
				}
				// Command
				else if (arg.IsAlpha)
				{
					if (commandCall != null)
						calls.Add(commandCall);
					commandCall = scope:: .();
				}
				// Multiple command calls (same options). Example: > install+add mypackage --verbose
				else if (arg.IsAlphaOr('+'))
				{
					extraCommands = scope:: .();
					for (let command in arg.Split('+'))
						extraCommands.Add(command);
				}
				// Option value
				else
				{
					commandCall.Options.Add(arg);
				}
			}

			// No commands called
			if (calls.IsEmpty)
			{
				Help();
				return;
			}

			for (let call in calls)
			{
				let result = GetCommand(call.Command);
				if (result case .Ok(let commandInstance))
					RunCommand(commandInstance, call.Options);
				else
					FatalError("Unknown command: {}", call.Command);
			}
		}

		private static void RunCommand(ICommand command, Span<String> options)
		{
			CurrentVerbosity = .Normal;

			for (let option in options)
			{
				switch (option)
				{
				case "--verbose", "-v":
					CurrentVerbosity = .Verbose;
					break;
				case "--quiet", "-q":
					CurrentVerbosity = .Quiet;
					break;
				}
			}

			for (let option in command.Info.Options)
			{
				var fieldResult = GetField(option.Name);
				if (fieldResult case .Ok(let field))
				{
					switch (field.FieldType)
					{
					case typeof(String):
						field.SetValue(command, GetStringOption(option.Name, option.Short));
						break;
					case typeof(String[]):
						field.SetValue(command, GetMultipleOptions(option.Name, option.Short));
						break;
					case typeof(bool):
						field.SetValue(command, GetOption(option.Name, option.Short));
						break;
					default:
						Error("Command option field has invalid type: {}", field.Name);
					}	
				}
				else
				{
					Error("Could not find field matching option: {}", option.Name);
				}
			}

			command.Execute();

			Result<FieldInfo> GetField(StringView name)
			{
				for (var field in command.GetType().GetFields())
					if (String.Compare(field.Name, name, true))
						return field;
				return .Err;
			}

			bool GetOption(StringView verbose, StringView short = "")
			{
				for (var option in options)
				{
					if (IsOption(option, verbose, short))
						return true;
				}

				return false;
			}

			Result<String> GetStringOption(StringView verbose, StringView short = "")
			{
				var enumerator = options.GetEnumerator();
				for (var option in enumerator)
				{
					if (IsOption(option, verbose, short))
					{
						if (enumerator.GetNext() case .Ok(let nextOption))
							return nextOption;
						else
							FatalError("Option {} has no corresponding value", option);
					}
				}
			}

			Result<List<String>> GetMultipleOptions(StringView verbose, StringView short = "")
			{
				/*var enumerator = options.GetEnumerator();
				var isOption = false;
				var result = scope List<String>();

				for (var option in enumerator)
				{
					if (IsOption(option, verbose, short))
					{
						isOption = true;
						continue;
					}

					if (!isOption)
						continue;

					if (option.StartsWith('-'))
						break;


				}*/
			}

			bool IsOption(StringView option, StringView verbose, StringView short = "")
			{
				if ((option.Length >= 3 && StringView(option, 2) == verbose) ||
					(option.Length >= 2 && StringView(option, 1) == short))
					return true;
				return false;
			}
		}

		public static Result<ICommand> GetCommand(StringView name)
		{
			for (var entry in Commands)
			{
				if (entry.Name == name)
					return entry.Instantiate();
			}

			return .Err;
		}

		public static void RegisterCommand<T>(StringView name) where T : ICommand
		{
			let entry = new CommandEntry(name, typeof(T));
			Commands.Add(entry);
		}

		public static bool Ask(StringView text)
		{
			bool DoAsk()
			{
				while (true)
				{
					Console.Write("{} [y/n] ", text);
					let char = Console.ReadKey();
					if (char == 'y')
						return true;
					else if (char == 'n')
						return false;
				}
			}

			bool answer = DoAsk();
			let length = 19 + text.Length;
			Console.EmptyLine(length);
			return answer;
		}

		public static void Warning(StringView fmt, params Object[] args) => Print(.Yellow, scope String()..AppendF("[Warning] {}", fmt), params args);

		public static void Error(StringView fmt, params Object[] args) => Print(.Red, scope String()..AppendF("[Error] {}", fmt), params args);

		public static void FatalError(StringView fmt, params Object[] args)
		{
			Error(fmt, params args);
			Cpp.exit(1);
		}

		public static void Success(StringView fmt, params Object[] args) => Print(.Green, scope String()..AppendF("[Success] {}", fmt), params args);

		public static void Info(StringView fmt, params Object[] args) => Print(.Cyan, scope String()..AppendF("[Info] {}", fmt), params args);

		public static void Print(StringView fmt, params Object[] args) => Print(.White, fmt, params args);

		public static void Print(ConsoleColor color, StringView fmt, params Object[] args)
		{
			if (CurrentVerbosity == .Quiet)
				return;

			let origin = Console.ForegroundColor;
			Console.ForegroundColor = color;
			Console.WriteLine(fmt, params args);
			Console.ForegroundColor = origin;
		}
	}
}
