using System;
using System.Collections;
using System.Linq;
using System.Reflection;

namespace bpm
{
	class Program
	{
		static List<ICommand> Commands = new List<ICommand>();

		static void Main()
		{
			var args = scope List<CommandArgument>();
			args.Add(new ValueArgument(null, "steak.logging"));
			args.Add(new FlagArgument("-global"));
			ExecuteCommand("install", args);

			Console.WriteLine("Done");
			Console.Read();

			delete Commands;
		}

		static void ExecuteCommand(String name, IEnumerable<CommandArgument> args)
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
					
					var methods = type.GetMethods();
					var methodResult = Linq.Where<MethodInfo>(methods, scope (i) => i.Name == "Execute").Single();
					if (methodResult case .Ok(let method))
					{
						let result = type.CreateObject();
						if (result case .Ok(var val))
						{
							var valueArguments = args.Where(scope (i) => i is ValueArgument);
							var flagArguments = args.Where(scope (i) => i is FlagArgument);
							var methodArguments = scope Object[method.ParamCount];

							for (int i = 0; i < method.ParamCount; ++i)
							{
								var pName = scope String();
								method.GetParamType(i).GetName(pName);
								var m = valueArguments.Where(scope (a) => a.Name == method.GetParamName(i));
								//Console.WriteLine("Param({}: {})  Value({})", method.GetParamName(i), pName, (m.Single() == .Err ? valueArguments.ElementAt(i).Get() : m.Single().Get()).Value);

								if (method.GetParamType(i) == typeof(StringView))
								{
									var matches = valueArguments.Where(scope (a) => a.Name == method.GetParamName(i));
									if (matches.Count() == 1)
										methodArguments[i] = (String) matches.Single().Get().Value;
									else
										methodArguments[i] = (String) args.ElementAt(i).Get().Value;

								}
								else if (method.GetParamType(i) == typeof(bool))
								{
									var matches = flagArguments.Where(scope (a) => a.Name == method.GetParamName(i));
									if (matches.Count() == 1)
										methodArguments[i] = (bool) matches.First().Get().Value;
									else
										methodArguments[i] = false;
								}
								else
								{
									var paramType = scope String();
									method.GetParamType(i).GetName(paramType);
									Console.WriteLine("Error: Invalid command parameter type: {}", paramType);
								}
							}

							method.Invoke(val, params methodArguments);
						}
						else if (result case .Err(let err))
						{
							Console.WriteLine("Error: Could not create command instance: {}", err);
						}
					}
					else
					{
						Console.WriteLine("Error: Command type '{}' does not have a Execute method", typename);
					}
				}	
			}
		}
	}
}
