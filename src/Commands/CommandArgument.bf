using System;

namespace Grill.Commands
{
	public abstract class CommandArgument
	{
		public String Name { get; }
		public Object Value { get; }
	}
}
