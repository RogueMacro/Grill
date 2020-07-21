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

		public bool IsUrl => IsDomain("");

		public bool IsDomain(StringView domain, bool isHttps = false)
		{
			int pos = 0;

			if (isHttps)
				_Match!("https");
			else
				_Match!("http");

			_Find!(':');
			_Match!("//");
			_Match!(domain);
			_Find!('/');

			return true;

			mixin _Find(char8 char)
			{
				while (this[pos] != char)
				{
					if (++pos >= Length)
						return false;
				}
			}

			mixin _Match(StringView string)
			{
				for (; pos < string.Length; pos++)
				{
					if (pos >= Length || string[pos] != this[pos])
						return false;
				}
			}
		}

		public static bool Compare(StringView strA, StringView strB, bool ignoreCase)
		{
			if (ignoreCase)
				return CompareOrdinalIgnoreCaseHelper(strA.Ptr, strA.Length, strB.Ptr, strB.Length) == 0;
			return CompareOrdinalHelper(strA.Ptr, strA.Length, strB.Ptr, strB.Length) == 0;
		}
	}
}
