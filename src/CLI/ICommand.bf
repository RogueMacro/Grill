using System;

namespace Grill.CLI
{
	public abstract class ICommand
	{
		public abstract CommandInfo Info { get; }

		public abstract void Execute();
	}
}
