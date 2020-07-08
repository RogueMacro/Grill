using System;

namespace Grill.CLI
{
	public class CommandEntry
	{
		public String Name = new .() ~ delete _;
		public Type Type;

		public this(StringView name, Type type)
		{
			if (type.IsSubtypeOf(typeof(ICommand)))
			{
				Name.Set(name);
				Type = type;
			}
			else
			{
				var typename = scope String();
				type.GetFullName(typename);
				CLI.Error("Invalid CommandEntry: Name = {}, Type = {}", name, typename);
			}
		}

		public ICommand Instantiate()
		{
			let result = this.Type.CreateObject();
			if (result case .Ok(let val))
				return (.) result.Get();

			CLI.Error("Could not instantiate command ({})", Name);
			return null;
		}
	}
}
