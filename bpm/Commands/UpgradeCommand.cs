using bpm.Logging;
using bpm.Packages;
using bpm.Utilities;
using ServiceStack;
using System.Linq;

namespace bpm.Commands
{
    public class UpgradeCommand : ICommand
    {
        public void Execute(string[] args)
        {
            if (args.Length == 0)
            {
                Log.Usage("upgrade <package> <version> [-global]");
                return;
            }

            string packageName = CommandTool.GetArgumentValueOrIndex("package", 0, ref args);
            bool isGlobal = CommandTool.GetArgument("-global", ref args);
            bool isForceUpgrade = CommandTool.GetArgument("-force", ref args);
            string version = CommandTool.GetArgumentValueOrIndex("version", 1, ref args) ?? "";
            if (version != "")
                Log.Warning("Version selection is not supported yet");

            if (args.Length != 0)
            {
                Log.Fatal("Invalid arguments: " + args.Join(", "), ExitCode.INVALID_ARGUMENTS);
                return;
            }

            if (!isForceUpgrade)
            {
                if (BpmPath.GetPackagePath(packageName) != null)
                {
                    var package = Package.FromInstalledPackageName(packageName);
                    var installedVersion = PackageVersion.FromInstalledPackageName(packageName);
                    var newVersion = PackageVersion.FromPackageName(packageName);
                    if (installedVersion.IsSameAs(newVersion))
                    {
                        Log.Info($"{package.Name} is already up-to-date");
                        return;
                    }
                }
            }

            var installArgs = isGlobal
                ? new string[] { "install", packageName, "-force", "-global" }
                : new string[] { "install", packageName, "-force" };
            Program.RunCommand(installArgs);
        }
    }
}
