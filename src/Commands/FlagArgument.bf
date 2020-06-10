using System;

namespace Grill.Commands
{
	public class FlagArgument : CommandArgument
	{
		public this(String name)
		{
			Name = name;
			Value = true;
		}
	}
}
