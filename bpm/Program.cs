using bpm.Commands;
using bpm.Logging;
using ServiceStack;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;

namespace bpm
{
    internal class Program
    {
        private static List<ICommand> Commands;

        private static void Main(string[] args)
        {
            AppDomain.CurrentDomain.FirstChanceException += Log.CatchExceptionEvent;
            AppDomain.CurrentDomain.UnhandledException += Log.CatchUnhandledExceptionEvent;

            Log.Init();

            Commands = Assembly.GetExecutingAssembly().GetTypes()
                .Where(t => typeof(ICommand).IsAssignableFrom(t) && t != typeof(ICommand))
                .Select(t => (ICommand) Activator.CreateInstance(t)).ToList();

            if (args.Length > 0)
            {
                RunCommand(args);
            }
            else
            {
                Console.WriteLine("Type 'exit' to stop.");

                Console.Write("> ");
                string line = Console.ReadLine();
                while (line != "exit")
                {
                    if (!line.IsNullOrEmpty())
                        RunCommand(line.Split());

                    Console.Write("> ");
                    line = Console.ReadLine();
                }
            }

            Environment.Exit((int) Log.LastExitCode);
        }

        public static void RunCommand(string[] args)
        {
            string commandName = args[0];

            ICommand command = null;
            try
            {
                command = Commands.Single(c =>
                    string.Compare(c.GetType().Name.Replace("Command", ""), commandName, StringComparison.OrdinalIgnoreCase) == 0);
            }
            catch (InvalidOperationException)
            {
                Log.Error($"{args[0].ToLower()} is not a command");
                return;
            }

            command.Execute(args.Skip(1).ToArray());
        }
    }
}