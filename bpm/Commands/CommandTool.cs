using bpm.Logging;
using ServiceStack;
using System;
using System.Collections.Generic;
using System.Linq;

namespace bpm.Commands
{
    public static class CommandTool
    {
        public static bool GetArgument(string arg, ref IEnumerable<string> args, bool removeArg = true)
        {
            for (int i = 0; i < args.Count(); i++)
            {
                if (args.ElementAt(i) == arg)
                {
                    if (removeArg)
                        args = args.Skip(i).ToArray();
                    return true;
                }
            }

            return false;
        }

        public static string GetArgument(int index, ref IEnumerable<string> args, bool removeArg = true)
        {
            if (args.Count() > index)
            {
                var arg = args.ElementAt(index);

                if (removeArg)
                {
                    var argList = args.ToList();
                    argList.RemoveAt(0);
                    args = argList.ToArray();
                }

                return arg;
            }

            return null;
        }

        public static string GetValueArgumentOrIndex(string name, int index, ref IEnumerable<string> args, bool removeArg = true)
        {
            string argValue;
            if ((argValue = GetValueArgument(name, ref args)) != null)
                return argValue;
            return GetArgument(index, ref args);
        }

        public static string GetValueArgument(string name, ref IEnumerable<string> args, bool removeArg = true)
        {
            var argList = args.ToList();
            foreach (var arg in argList)
            {
                if (arg.StartsWith(name))
                {
                    if (!arg.Contains("="))
                    {
                        Log.Error($"Argument '{name}' is has no value");
                        return null;
                    }

                    var split = arg.Split("=");
                    var value = split.Length == 2 ? split[1] : "";
                    if (removeArg)
                        argList.Remove(arg);
                    args = argList.ToArray();
                    return value;
                }
            }

            return null;
        }
    }
}