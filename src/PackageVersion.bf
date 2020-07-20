using System;

namespace Grill
{
	public class PackageVersion
	{
		public readonly int Major;
		public readonly int Minor;
		public readonly int Patch;

		public this()
		{
			Major = 0;
			Minor = 0;
			Patch = 0;
		}

		public this(StringView version)
		{
			var numbers = version.Split('.');
			Major = int.Parse(numbers.GetNext());
			Minor = int.Parse(numbers.GetNext());
			Patch = int.Parse(numbers.GetNext());
		}

		public this(int major, int minor, int patch)
		{
			Major = major;
			Minor = minor;
			Patch = patch;
		}

		public bool IsGreaterThan(PackageVersion other)
		{
			return (Major > other.Major || (Major == other.Major &&
					Minor > other.Minor || (Minor == other.Major &&
					Patch > other.Patch)));
		}

		public bool IsGreaterThanOrEqualTo(PackageVersion other)
		{
			if (Major == other.Major &&
				Minor == other.Minor &&
				Patch == other.Patch)
				return true;

			return IsGreaterThan(other);
		}

		public override void ToString(String strBuffer)
		{
			strBuffer.AppendF("{}.{}.{}", Major, Minor, Patch);
		}
	}
}
