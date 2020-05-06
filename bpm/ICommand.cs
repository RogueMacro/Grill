using System;
using System.Collections.Generic;
using System.Text;

namespace bpm
{
    public interface ICommand
    {
        public void Execute(string[] args);
    }
}
