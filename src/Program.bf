using bpm.Commands;
using System;
using System.Collections;
using System.Reflection;

namespace bpm
{
	class Program
	{
		static List<ICommand> Commands = new List<ICommand>();

		static void Main()
		{
			var args = scope List<CommandArgument>();
			args.Add(scope ValueArgument(null, "steak.logging"));
			args.Add(scope FlagArgument("-global"));
			ExecuteCommand("install", args);

			Console.WriteLine("Done");
			Console.In.Read();

			delete Commands;
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
					Console.WriteLine("Executing command: {}", typename);
					
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

							for (int i = 0; i < method.ParamCount; ++i)
							{
								var vName = method.GetParamName(i);

								if (method.GetParamType(i) == typeof(StringView))
								{
									Result<ValueArgument> ra = .Err;
									for (var va in valueArguments)
										if (va.Name == vName)
											ra = .Ok(va);

									if (ra case .Ok(var argVal))
										methodArguments[i] = scope::box StringView(scope:: String((String) argVal.Value));
									else
										methodArguments[i] = scope::box StringView(scope:: String((String) args[i].Value));

								}
								else if (method.GetParamType(i) == typeof(bool))
								{
									Result<ValueArgument> ra = .Err;
									for (var va in valueArguments)
										if (va.Name == vName)
											ra = .Ok(va);

									if (ra case .Ok(let argVal))
										methodArguments[i] = scope::box bool((bool) argVal.Value);
									else
										methodArguments[i] = scope::box false;
								}
								else
								{
									var paramType = scope String();
									method.GetParamType(i).GetName(paramType);
									Console.WriteLine("Error: Invalid command parameter type: {}", paramType);
								}
							}

							method.Invoke(val, params methodArguments);
							delete val;
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
		}
	}
}
