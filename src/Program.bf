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
		public static bool IsDebug = false;

		public static List<ICommand> Commands = new List<ICommand>();

		static void Main(String[] args)
		{
			if (args.Count > 1)
			{
				var parsedArguments = scope List<CommandArgument>();
				String command = null;

				bool first = true;
				for (let arg in args)
				{
					if (first)
					{
						command = scope:: String(arg);
						first = false;
					}

					if (arg.StartsWith("-"))
					{
						parsedArguments.Add(scope:: FlagArgument(scope:: String(arg, 1)));
					}
					else
					{
						int i = 0;
						for (var char in arg.RawChars)
						{
							if (char.IsLetter)
							{
								++i;
							}
							else if (char == '=')
							{
								parsedArguments.Add(scope:: ValueArgument(scope:: String(arg, 0, i), scope:: String(arg, i, arg.Length)));
								break;
							}
							else
							{
								parsedArguments.Add(scope:: ValueArgument(null, scope:: String(arg)));
								break;
							}
						}
					}
				}

				for (let arg in parsedArguments)
				{
					if (arg.Name == "ddebug")
					{
						IsDebug = true;
						parsedArguments.Remove(arg);
						Warning("Debug mode is on");
					}
				}

				Git.Init();

				ExecuteCommand(command, parsedArguments);
			}
			else
			{
				Error("No arguments given");
			}

			Console.WriteLine("Done");
			Console.In.Read();

			delete Commands;
		}

		public static void Debug(StringView fmt, params Object[] args) => Debug(.Gray, fmt, params args);
		
		public static void Debug(ConsoleColor color, StringView fmt, params Object[] args)
		{
			if (IsDebug)
				Print(color, scope String()..AppendF("[Debug] {}", fmt), params args);
		}

		public static void Warning(StringView fmt, params Object[] args) => Print(.Yellow, scope String()..AppendF("[Warning] {}", fmt), params args);

		public static void Error(StringView fmt, params Object[] args) => Print(.Red, scope String()..AppendF("[Error] {}", fmt), params args);

		public static void Success(StringView fmt, params Object[] args) => Print(.Green, scope String()..AppendF("[Success] {}", fmt), params args);
	
		public static void Info(StringView fmt, params Object[] args) => Print(.Cyan, scope String()..AppendF("[Info] {}", fmt), params args);

		public static void Print(StringView fmt, params Object[] args) => Print(.White, fmt, params args);

		public static void Print(ConsoleColor color, StringView fmt, params Object[] args)
		{
			let origin = Console.ForegroundColor;
			Console.ForegroundColor = color;
			Console.WriteLine(fmt, params args);
			Console.ForegroundColor = origin;
		}

		static void ExecuteCommand(String name, List<CommandArgument> args)
		{
			var expectedTypename = scope String(name)..Append("command");
			
			for (let typeId < Type.TypeIdEnd)
			{
				let type = Type.[Friend]GetType(typeId);
				String typename = scope .();
				type?.GetName(typename);

				if (String.Compare(typename, expectedTypename, true) == 0 && type != typeof(ICommand))
				{
					var methodResult = type.GetMethod("Execute");
					if (methodResult case .Ok(let method))
					{
						let result = type.CreateObject();
						if (result case .Ok(let val))
						{
							var valueArguments = scope List<ValueArgument>();
							for (var arg in args)
							{
								var carg = arg as ValueArgument;
								if (carg != null)
									valueArguments.Add(carg);
							}	

							var flagArguments = scope List<FlagArgument>();
							for (var arg in args)
							{
								var carg = arg as FlagArgument;
								if (carg != null)
									flagArguments.Add(carg);
							}	
							var methodArguments = scope Object[method.ParamCount];

							int i = 0;
							for (i = 0; i < methodArguments.Count; ++i)
							{
								var vName = method.GetParamName(i);

								if (method.GetParamType(i) == typeof(String))
								{
									if (i >= args.Count || args[i] is FlagArgument)
									{
										methodArguments[i] = scope:: String();
										continue;
									}

									Result<ValueArgument> ra = .Err;
									for (var va in valueArguments)
										if (va.Name == vName)
											ra = .Ok(va);

									if (ra case .Ok(var argVal))
										methodArguments[i] = scope:: String((String) argVal.Value);
									else
										methodArguments[i] = scope:: String((String) args[i].Value);

								}
								else if (method.GetParamType(i) == typeof(bool) || args[i] is FlagArgument)
								{
									break;
								}
								else
								{
									var paramType = scope String();
									method.GetParamType(i).GetName(paramType);
									Console.WriteLine("Error: Invalid command parameter type: {}", paramType);
								}
							}

							for (i = i; i < methodArguments.Count; ++i)
							{
								var vName = method.GetParamName(i);

								if (method.GetParamType(i) == typeof(bool))
								{
									bool isArg = false;
									for (var va in flagArguments)
										if (va.Name == vName)
											isArg = true;

									methodArguments[i] = scope::box isArg;
								}
								else
								{
									var paramType = scope String();
									method.GetParamType(i).GetName(paramType);
									Console.WriteLine("Error: Invalid command parameter type: {}", paramType);
								}
							}

							method.Invoke(val, params methodArguments);
							delete result.Value;
							return;
						}
						else if (result case .Err(let err))
						{
							Console.WriteLine("Error: Could not create command instance: {}", err);
						}
					}
					else if (methodResult case .Err(let err))
					{
						Console.WriteLine("Error: Could not get execute method from '{}' ({})", typename, err);
					}
				}	
			}

			Error("{} is not a command", name);
		}

		public static bool Ask(StringView text)
		{
			repeat
			{
				Console.Write("[Question] {} [y/n] ", text);
				var buffer = scope String();
				Console.In.ReadLine(buffer);
				buffer.ToLower();
				if (buffer == "y" || buffer == "yes")
					return true;
				else if (buffer == "n" || buffer == "n")
					return false;
			} while (true)
		}
	}
}
