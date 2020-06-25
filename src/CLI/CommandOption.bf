using System;
using System.Collections;

namespace Grill.CLI
{
	public class CommandOption
	{
		public String Name = new .() ~ delete _;
		public String Description = new .() ~ delete _;

		public bool IsRequired = false;

		public String Short = new .() ~ delete _;

		public List<String> Requires = new .() ~ DeleteContainerAndItems!(_);
		public List<String> ConflictsWith = new .() ~ DeleteContainerAndItems!(_);

		public this(StringView name, StringView description)
		{
			Name.Set(name);
			Description.Set(description);
		}

		public Self Required()
		{
			IsRequired = true;
			return this;
		}

		public Self Short(StringView short)
		{
			Short.Set(short);
			return this;
		}

		public Self ConflictsWith(params StringView[] conflicts)
		{
			for (let conflict in conflicts)
				ConflictsWith.Add(new String(conflict));
			return this;
		}

		public Self Requires(params StringView[] requires)
		{
			for (let require in requires)
				Requires.Add(new String(require));
			return this;
		}	
	}
}
