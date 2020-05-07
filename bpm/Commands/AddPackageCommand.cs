using bpm.Logging;
using bpm.Utilities;
using Nett;
using ServiceStack;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;

namespace bpm.Commands
{
    public class AddPackageCommand : ICommand
    {
        public string[] Aliases => new string[] { "add" };
        public bool RequiresArguments => true;
        public string Usage => "add <package> [path] [-global] [-copy]";

        public void Execute(IEnumerable<string> args)
        {
            var packageName = CommandTool.GetValueArgumentOrIndex("package", 0, ref args);
            var projectPath = CommandTool.GetValueArgumentOrIndex("path", 0, ref args) ?? "";
            bool isGlobal = CommandTool.GetArgument("-global", ref args);
            bool isCopy = CommandTool.GetArgument("-copy", ref args);
            
            var tomlPath = Path.Combine(projectPath, "BeefSpace.toml");

            if (args.Count() != 0)
            {
                Log.Fatal("Invalid arguments: " + args.Join(", "), ExitCode.INVALID_ARGUMENTS);
                return;
            }

            var toml = Toml.ReadFile(tomlPath);

            var projects = new Dictionary<string, Dictionary<string, object>>();
            bool workspaceHasProjects = toml.ContainsKey("Projects");
            
            if (workspaceHasProjects)
                projects = toml["Projects"].Get<Dictionary<string, Dictionary<string, object>>>();

            var packageTomlProject = new Dictionary<string, object>();
            packageTomlProject["Path"] = BpmPath.GetPackagePath(packageName, isGlobal);
            projects[packageName] = packageTomlProject;

            if (workspaceHasProjects)
                toml.Remove("Projects");
            toml.Add("Projects", projects);

            bool workspaceHasLocked = toml.ContainsKey("Locked");
            var locked = new List<string>();
            if (workspaceHasLocked)
                locked = toml.Get<List<string>>("Locked");

            locked.Add(packageName);
            if (workspaceHasLocked)
                toml.Remove("Locked");
            toml.Add("Locked", locked);

            Toml.WriteFile(toml, tomlPath);
        }
    }
}
