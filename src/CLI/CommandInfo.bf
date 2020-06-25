using System;
using System.Collections;

namespace Grill.CLI
{
	public class CommandInfo
	{
		public String Name = new .() ~ delete _;

		public String About = new .() ~ delete _;

		public List<CommandOption> Options = new .() ~ DeleteContainerAndItems!(_);

		public this(StringView name)
		{
			Name.Set(name);
		}

		public Self About(StringView about)
		{
			About.Set(about);
			return this;
		}

		public Self Option(CommandOption option)
		{
			Options.Add(option);
			return this;
		}
	}
}
