using bpm.Logging;
using System;
using System.Linq;

namespace bpm.Commands
{
    public static class CommandTool
    {
        public static bool GetArgument(string arg, ref string[] args, bool removeArg = true)
        {
            if (args.Contains(arg))
            {
                if (removeArg)
                {
                    var argList = args.ToList();
                    argList.Remove(arg);
                    args = argList.ToArray();
                }

                return true;
            }

            return false;
        }

        public static string GetArgument(int index, ref string[] args, bool removeArg = true)
        {
            if (args.Length > index)
            {
                var arg = args[index];

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

        public static string GetArgumentValueOrIndex(string name, int index, ref string[] args, bool removeArg = true)
        {
            string argValue;
            if ((argValue = GetArgumentValue(name, ref args)) != null)
                return argValue;

            return GetArgument(index, ref args);
        }

        public static string GetArgumentValue(string name, ref string[] args, bool removeArg = true)
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