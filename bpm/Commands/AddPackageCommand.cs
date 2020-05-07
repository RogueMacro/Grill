using bpm.Logging;
using bpm.Packages;
using bpm.Utilities;
using Nett;
using ServiceStack;
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

        public void Execute(string[] args)
        {
            var packageName = CommandTool.GetValueArgumentOrIndex("package", 0, ref args);
            var projectPath = CommandTool.GetValueArgumentOrIndex("path", 0, ref args) ?? "";
            bool isGlobal = CommandTool.GetArgument("-global", ref args);
            bool isCopy = CommandTool.GetArgument("-copy", ref args);
            
            var tomlPath = Path.Combine(projectPath, "BeefSpace.toml");
            var packagePath = BpmPath.GetPackagePath(packageName, isGlobal);

            if (args.Count() != 0)
            {
                Log.Fatal("Invalid arguments: " + args.Join(", "), ExitCode.INVALID_ARGUMENTS);
                return;
            }

            if (isCopy)
            {
                var packageDestinationPath = Path.Combine(projectPath, "packages", packageName);

                if (Directory.Exists(packageDestinationPath))
                {
                    bool proceed = Input.GetChoice($"A custom version of {packageName} already exist in this workspace. Do you want to overwrite it?");
                    if (!proceed)
                        return;

                    BpmPath.DeleteDirectory(packageDestinationPath);
                }

                foreach (string dirPath in Directory.GetDirectories(packagePath, "*",
                    SearchOption.AllDirectories))
                    Directory.CreateDirectory(dirPath.Replace(packagePath, packageDestinationPath));

                foreach (string newPath in Directory.GetFiles(packagePath, "*.*",
                    SearchOption.AllDirectories))
                    File.Copy(newPath, newPath.Replace(packagePath, packageDestinationPath), true);

                packagePath = Path.Combine("packages", packageName);
            }

            var toml = Toml.ReadFile(tomlPath);

            var projects = new Dictionary<string, Dictionary<string, object>>();
            bool workspaceHasProjects = toml.ContainsKey("Projects");
            
            if (workspaceHasProjects)
                projects = toml["Projects"].Get<Dictionary<string, Dictionary<string, object>>>();

            var packageTomlProject = new Dictionary<string, object>();
            packageTomlProject["Path"] = packagePath;
            projects[packageName] = packageTomlProject;

            if (workspaceHasProjects)
                toml.Remove("Projects");
            toml.Add("Projects", projects);

            bool workspaceHasLocked = toml.ContainsKey("Locked");
            var locked = new List<string>();
            if (workspaceHasLocked)
                locked = toml.Get<List<string>>("Locked");

            if (!isCopy)
            {
                locked.Add(packageName);
                if (workspaceHasLocked)
                    toml.Remove("Locked");
                toml.Add("Locked", locked);
            }

            Toml.WriteFile(toml, tomlPath);
        }
    }
}
