namespace System.Collections
{
	extension List<T> where T : delete
	{
		public bool DeleteAndRemove(T item)
		{
			int index = IndexOf(item);
			if (index != -1)
			{
				delete this[index];
				RemoveAt(index);
				return true;
			}

			return false;
		}

		public bool DeleteAndRemoveAt(int index)
		{
			if (Count > 0)
			{
				delete this[index];
				RemoveAt(index);
				return true;
			}

			return false;
		}
	}

	extension List<T>
	{
		public Result<T> Last()
		{
			if (Count == 0)
				return .Err;
			return this[Count-1];
		}
	}
}
