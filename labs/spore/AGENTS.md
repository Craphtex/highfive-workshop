# För Codex

Det här labbet är skrivet för Claude Code. Manualen är `CLAUDE.md` i den här mappen: läs den först, den gäller dig också.

Så översätter du Claude Code-mekanismerna:

- **Slash-kommandon** ligger i `.claude/commands/<namn>.md`. Skriver användaren `/start` (eller något annat kommando som finns där) läser du den filen och följer den som om den vore användarens prompt. Argument efter kommandot ersätter `$ARGUMENTS`.
- **Agenter** i `.claude/agents/*.md` (och `capabilities/`, `flux/genome/` där det finns) är roller. Säger ett kommando att en agent ska göra något: läs agentens fil, anta rollen och gör jobbet i den här konversationen, en roll i taget. Du har inga parallella subagenter, det är i sin ordning.
- **Filer som kommandona skapar** (nya agenter, kandidater, tidslinjer, kyrkogårdsposter) skriver du precis som beskrivet. Det är filsystemet som är tillståndet, inte sessionen.
- **Skills** under `.claude/skills/` hittar du också via `.agents/skills/`.

Svenska i allt du skriver till användaren, med korrekta å, ä och ö.
