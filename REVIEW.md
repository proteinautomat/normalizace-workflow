# 🔍 Code Review – Normalizace Workflow

**Datum:** 2025-11-11  
**Autor:** Codex (GPT-5)

## Návrhy změn

1. `.github/workflows/auto-codex-review.yml:40-55` – Workflow má napevno `REPO="proteinautomat/brani-sklad"`, takže odkaz na diff a GitHub porovnání vždy míří do úplně jiného repozitáře. Na tomto repu se pak po spuštění akce zobrazuje prázdná/nesouvisející změna. Opravit na `${{ github.repository }}` (případně načíst owner/repo z kontextu) a tím pádem generovat compare URL pro aktuální projekt.
2. `.github/workflows/auto-codex-review.yml:97-178` – V horní části instrukcí žádáš člověka, aby upravil `REVIEW.md`, ale později ve stejném jobu soubor znovu vytváříš s pevně daným textem „✅ Approved“ a rovnou ho pushuješ zpět do větve. Výsledkem je, že ruční poznámky nikdy nepřežijí, akce vždy automaticky schválí změny a každé spuštění přidává další commit. Navrhnu rozdělit chování: buď generovat jen instrukce a necommittovat nic, nebo commitovat výsledek, ale pak nepožadovat manuální edit.
3. `.workflow-main.sh:62-70` – Funkce `init_state` zapisuje JSON přes `cat << 'EOF'`, takže výraz `$(date -u ...)` se nespustí a do souboru se uloží doslova text `$(date -u +%Y-%m-%dT%H:%M:%SZ)`. Stavový soubor tak nikdy neobsahuje skutečné časové razítko. Stačí odstranit uvozovky kolem `EOF` nebo vložit timestamp jinak (např. přes `DATE=$(date -u ...); cat <<EOF ... $DATE`).

## Implementace oprav

✅ **Všechny opravy byly implementovány (commit 032835c)**

### Fix #1: Hard-coded repo ✅
- Změněno: `REPO="proteinautomat/brani-sklad"` → `REPO="${{ github.repository }}"`
- Výsledek: GitHub diff URL se nyní generuje pro aktuální projekt, ne fixní repo
- Status: DONE

### Fix #2: REVIEW.md přepisování ✅
- Změněno: Automatické vytváření a commitování REVIEW.md odstraněno
- Nové chování: Workflow jen vygeneruje instrukce, uživatel ručně vytvoří REVIEW.md
- Výsledek: Manuální poznámky se už neztratí
- Status: DONE

### Fix #3: Timestamp v init_state ✅
- Změněno: `<< 'EOF'` → `<< EOF` (bez single quotes)
- Výsledek: $(date -u ...) se nyní expanduje na skutečný timestamp v ISO 8601 formátu
- Status: DONE

## Testování

- Po opravě spusť GitHub Action na testovací větvi a ověř:
  - ✅ GitHub diff URL ukazuje do správného repozitáře
  - ✅ REVIEW.md se již nepřepisuje automaticky
  - ✅ Timestamp se ukládá správně

---

**Aktualizováno:** 2025-11-11 (commit 032835c)
**Všechny body z code review byly zaimplementovány a pushnuty na master**
