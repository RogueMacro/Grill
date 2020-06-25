namespace System
{
	extension String
	{
		public bool IsAlpha
		{
			get
			{
				for (let char in this.RawChars)
					if (!char.IsLetter)
						return false;
				return true;
			}
		}

		public bool IsAlphaOr(params char8[] chars)
		{
			RawCharLoop:
			for (let rawChar in this.RawChars)
			{
				if (!rawChar.IsLetter)
				{
					for (let char in chars)
						if (char == rawChar)
							continue RawCharLoop;

					return false;
				}
			}

			return true;
		}

		public static bool Compare(StringView strA, StringView strB, bool ignoreCase)
		{
			if (ignoreCase)
				return CompareOrdinalIgnoreCaseHelper(strA.Ptr, strA.Length, strB.Ptr, strB.Length) == 0;
			return CompareOrdinalHelper(strA.Ptr, strA.Length, strB.Ptr, strB.Length) == 0;
		}
	}
}
