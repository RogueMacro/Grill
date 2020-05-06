using System;
using System.Linq;
using System.Reflection;

namespace bpm
{
    class Program
    {
        static void Main(string[] args)
        {
            var commands = Assembly.GetExecutingAssembly().GetTypes()
                .Where(t => typeof(ICommand).IsAssignableFrom(t) && t != typeof(ICommand))
                .Select(t => (ICommand) Activator.CreateInstance(t));

            if (args.Length > 0)
            {
                var command = commands.Single(c => c.GetType().Name.ToLower().Replace("command", "") == args[0].ToLower());
                command.Execute(args.Skip(1).ToArray());
            }
        }
    }
}
