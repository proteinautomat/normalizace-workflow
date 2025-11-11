# 🔍 Code Review – Normalizace Workflow

**Datum:** 2025-11-11  
**Autor:** Codex (GPT-5)

## Návrhy změn

1. `.github/workflows/auto-codex-review.yml:40-55` – Workflow má napevno `REPO="proteinautomat/brani-sklad"`, takže odkaz na diff a GitHub porovnání vždy míří do úplně jiného repozitáře. Na tomto repu se pak po spuštění akce zobrazuje prázdná/nesouvisející změna. Opravit na `${{ github.repository }}` (případně načíst owner/repo z kontextu) a tím pádem generovat compare URL pro aktuální projekt.
2. `.github/workflows/auto-codex-review.yml:97-178` – V horní části instrukcí žádáš člověka, aby upravil `REVIEW.md`, ale později ve stejném jobu soubor znovu vytváříš s pevně daným textem „✅ Approved“ a rovnou ho pushuješ zpět do větve. Výsledkem je, že ruční poznámky nikdy nepřežijí, akce vždy automaticky schválí změny a každé spuštění přidává další commit. Navrhnu rozdělit chování: buď generovat jen instrukce a necommittovat nic, nebo commitovat výsledek, ale pak nepožadovat manuální edit.
3. `.workflow-main.sh:62-70` – Funkce `init_state` zapisuje JSON přes `cat << 'EOF'`, takže výraz `$(date -u ...)` se nespustí a do souboru se uloží doslova text `$(date -u +%Y-%m-%dT%H:%M:%SZ)`. Stavový soubor tak nikdy neobsahuje skutečné časové razítko. Stačí odstranit uvozovky kolem `EOF` nebo vložit timestamp jinak (např. přes `DATE=$(date -u ...); cat <<EOF ... $DATE`).

## Doporučení

- Po opravě výše uvedeného spusť GitHub Action na testovací větvi a ověř, že odkazy vedou do správného repozitáře a že se `REVIEW.md` už nepřepisuje automaticky.
- U `init_state` přidej jednotný formát ISO 8601; stav pak lze číst i ve skriptech, které očekávají reálný čas.
