namespace bpm.Commands
{
    public interface ICommand
    {
        public string[] Aliases { get; }
        public bool RequiresArguments { get; }
        public string Usage { get; }

        public void Execute(string[] args);
    }
}