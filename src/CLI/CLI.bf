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
					commandCall.Options.Add(new String()..Set(arg));
				}
				// Command
				else if (arg.IsAlpha)
				{
					if (calls.Count > 0)
					{
						calls.Add(commandCall);
						commandCall = scope:: .();
					}

					commandCall.Command.Set(arg);
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
					commandCall.Options.Add(new String()..Set(arg));
				}
			}

			if (!commandCall.Command.IsEmpty)
				calls.Add(commandCall);

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
				{
					RunCommand(commandInstance, call.Options);
					delete commandInstance;
				}
				else
					FatalError("Unknown command: {}", call.Command);
			}
		}

		private static void RunCommand(ICommand command, List<String> options)
		{
			CurrentVerbosity = .Normal;

			for (let option in options)
			{
				switch (option)
				{
				case "--verbose", "-v":
					CurrentVerbosity = .Verbose;
					options.DeleteAndRemove(option);
					break;
				case "--quiet", "-q":
					CurrentVerbosity = .Quiet;
					options.DeleteAndRemove(option);
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
					case typeof(List<String>):
						var optionValues = GetMultipleOptions(option.Name, option.Short);
						field.SetValue(command, optionValues);
						for (var value in optionValues)
							options.Remove(value);
						break;
					case typeof(bool):
						field.SetValue(command, GetOption(option.Name, option.Short));
						break;
					default:
						var typename = scope String();
						field.FieldType.GetName(typename);
						FatalError("Command option field '{}' has invalid type: {}", field.Name, typename);
					}

					RemoveOption(option.Name, option.Short);
				}
				else
					FatalError("Could not find field matching option: {}", option.Name);
			}

			if (options.Count == 1)
				FatalError("Unknown option: {}", options[0]);
			else if (options.Count > 1)
			{
				var str = scope String()..Join(", ", options.GetEnumerator());
				FatalError("Unknown options: {}", str);
			}

			command.Execute();

			void RemoveOption(String verbose, String short)
			{
				for (var option in options)
				{
					if (IsOption(option, verbose, short))
					{
						options.DeleteAndRemove(option);
						break;
					}
				}
			}

			Result<FieldInfo> GetField(StringView name)
			{
				for (var field in command.GetType().GetFields())
					if (String.Compare(field.Name, name, true))
						return field;
				return .Err;
			}

			bool GetOption(String verbose, String short = "")
			{
				for (var option in options)
				{
					if (IsOption(option, verbose, short))
						return true;
				}

				return false;
			}

			Result<String> GetStringOption(String verbose, String short = "")
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

				return .Err;
			}

			List<String> GetMultipleOptions(String verbose, String short = "")
			{
				var enumerator = options.GetEnumerator();
				var isOption = false;
				var containsOption = options.Contains(verbose) || options.Contains(short);
				var result = new List<String>();

				for (var option in enumerator)
				{
					if (!isOption)
					{
						if ((!containsOption && !option.StartsWith('-')) ||
							(containsOption && IsOption(option, verbose, short)))
							isOption = true;
						else
							continue;
					}
					
					if (option.StartsWith('-'))
						break;

					result.Add(option);
				}

				return result;
			}

			bool IsOption(String option, String verbose, String short = "")
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
#if DEBUG
			Console.Write("Press any key to exit...");
			Console.ReadKey();
#endif
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
