using System;

namespace bpm.Commands
{
	public abstract class CommandArgument
	{
		public String Name { get; }
		public Object Value { get; }
	}
}
