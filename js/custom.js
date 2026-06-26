/*
 * Platz für eigenes Javascript
 * Die hier gemachten Änderungen überschreiben ggfs. andere Funktionen, da diese Datei als letzte geladen wird.
 */

// Rundet Rabatt-Badges auf ganze Prozent (z.B. -11.95% -> -12%)
(function iwDiscountBadgeRound(){
  function roundBadge(badge){
    if(!badge) return;
    const raw = (badge.textContent || "").trim();
    const m = raw.match(/-?\d+(?:[.,]\d+)?/);
    if(!m) return;
    const num = parseFloat(m[0].replace(",", "."));
    if(!isFinite(num)) return;
    const rounded = Math.round(num);
    const sign = raw.includes("-") || num < 0 ? "-" : "";
    badge.textContent = `${sign}${Math.abs(rounded)}%`;
    if(badge.getAttribute("title")){
      badge.setAttribute("title", badge.getAttribute("title").replace(/-?\d+(?:[.,]\d+)?%?/, `${sign}${Math.abs(rounded)}%`));
    }
  }

  function run(){
    document.querySelectorAll(".iw-discount-badge").forEach(roundBadge);
  }

  if(document.readyState === "loading"){
    document.addEventListener("DOMContentLoaded", run);
  } else {
    run();
  }
})();


// Erzwingt/rekonstruiert ein %-Badge auf der Produktdetailseite.
// Fallbacks:
// - nutzt vorhandenes .yousave .percent (Plugin)
// - oder berechnet aus VK + UVP/Streichpreis im DOM
// Zusätzlich werden versehentlich unter .price-note ausgegebene UVP/Statt-Elemente in die Inline-Preiszeile gezogen.
(function iwEnsureDiscountBadge(){
  function parsePercent(text){
    if(!text) return NaN;
    const m = String(text).match(/-?\d+(?:[.,]\d+)?/);
    if(!m) return NaN;
    const num = parseFloat(m[0].replace(",", "."));
    return isFinite(num) ? Math.abs(num) : NaN;
  }

  function parseMoney(text){
    if(!text) return NaN;
    let s = String(text)
      .replace(/\s/g, "")
      .replace(/[^\d,.-]/g, "");
    if(!s) return NaN;

    // Deutsch: 1.234,56 -> 1234.56
    if(s.includes(",")){
      s = s.replace(/\./g, "").replace(",", ".");
    }
    const n = parseFloat(s);
    return isFinite(n) ? n : NaN;
  }

  function moveBestReferenceIntoRow(wrapper, row){
    if(!wrapper || !row) return;

    // Wenn in der Preiszeile schon UVP vorhanden ist, alte "statt"-Referenz entfernen.
    const rowUvp = row.querySelector(".iw-uvp-inline");
    const rowOld = row.querySelector(".iw-old-price-inline");
    if(rowUvp && rowOld){
      rowOld.remove();
      return;
    }

    if(rowUvp || rowOld) return;

    const candidates = Array.from(wrapper.querySelectorAll(
      ".price-note .iw-uvp-inline, .price-note .iw-old-price-inline, .price-note .suggested-price, .price-note .uvp, .price-note .old-price, .price-note .instead-of"
    )).filter(el => el && el.querySelector && el.querySelector("del, s, .value"));

    if(!candidates.length) return;

    // UVP bevorzugen, sonst ersten Streichpreis nehmen.
    let chosen = candidates.find(el => /uvp|unverbind|suggested/i.test(el.textContent || "")) || candidates[0];

    // In Inline-Zeile verschieben, nicht duplizieren.
    chosen.classList.add(/uvp|unverbind|suggested/i.test(chosen.textContent || "") ? "iw-uvp-inline" : "iw-old-price-inline");
    row.appendChild(chosen);

    // Falls sowohl "statt" als auch UVP in price-note standen: Rest entfernen.
    candidates.forEach(el => {
      if(el !== chosen) el.remove();
    });
  }

  function ensureBadgeForWrapper(wrapper){
    if(!wrapper) return;

    const row = wrapper.querySelector(".iw-price-inline-row");
    if(!row) return;

    moveBestReferenceIntoRow(wrapper, row);

    // Wenn bereits Badge vorhanden: nur sicher runden.
    let badge = row.querySelector(".iw-discount-badge");
    if(badge){
      const p = parsePercent(badge.textContent);
      if(isFinite(p) && p > 0){
        const rounded = Math.round(p);
        badge.textContent = `-${rounded}%`;
        badge.setAttribute("title", `Du sparst ${rounded}%`);
      }
      return;
    }

    // Prozent aus Plugin nehmen, falls vorhanden.
    let p = parsePercent(wrapper.querySelector(".price-note .yousave .percent")?.textContent);

    // Sonst aus VK + Referenzpreis berechnen.
    if(!isFinite(p) || p <= 0){
      const current = parseMoney(row.querySelector(".price")?.textContent);
      const ref = parseMoney(row.querySelector(".iw-uvp-inline del, .iw-uvp-inline s, .iw-old-price-inline del, .iw-old-price-inline s, .iw-uvp-inline .value, .iw-old-price-inline .value")?.textContent);
      if(isFinite(current) && isFinite(ref) && ref > current){
        p = ((ref - current) / ref) * 100;
      }
    }

    if(!isFinite(p) || p <= 0) return;

    const rounded = Math.round(p);
    badge = document.createElement("span");
    badge.className = "iw-discount-badge";
    badge.textContent = `-${rounded}%`;
    badge.setAttribute("title", `Du sparst ${rounded}%`);

    const priceEl = row.querySelector(".price");
    if(priceEl && priceEl.nextSibling){
      row.insertBefore(badge, priceEl.nextSibling);
    } else {
      row.appendChild(badge);
    }
  }

  function run(){
    document.querySelectorAll(".product-detail .price_wrapper").forEach(ensureBadgeForWrapper);
  }

  if(document.readyState === "loading"){
    document.addEventListener("DOMContentLoaded", run);
  } else {
    run();
  }
  // Fallback für nachträgliche Plugin-/Template-Injektionen. Ja, hässlich. Dafür robust.
  setTimeout(run, 250);
})();

/* =========================================================
   Globale Fahrzeug-Helfer (Desktop + Mobile)
   ========================================================= */
const IW_VEHICLE_BRANDS = ["Abarth","Alfa Romeo","Citroën","DS","Fiat","Jeep","Lancia","Leapmotor","Opel","Peugeot"];

function iwNormLabel(s){
  return (s||"").toString()
    .replace(/[\u200B-\u200D\uFEFF]/g,"")
    .replace(/[\u00A0\u202F]/g," ")
    .replace(/\s+/g," ")
    .trim();
}

function getBrandFromPrefixedValue(v){
  const val = iwNormLabel(v);
  for(const b of IW_VEHICLE_BRANDS){
    const p = b + " ";
    if(val.startsWith(p)) return b;
    if(b === "Citroën" && val.startsWith("Citroen ")) return "Citroën";
  }
  return "";
}

function stripPrefix(v, brand){
  const val = iwNormLabel(v);
  const p = brand + " ";
  if(val.startsWith(p)) return val.slice(p.length);
  if(brand === "Citroën" && val.startsWith("Citroen ")) return val.slice("Citroen ".length);
  return val;
}

/* =========================================================
   IW Vehicle Facet Logic (DESKTOP v11-desktop-fix2)
   ========================================================= */
(function iwVehicleFacetsDesktop(){
  window.IW_VEHICLE_FACETS_VERSION = "v11-desktop-fix5-scope-debug";
  try{ console.log("IW vehicle facets v11-desktop-fix5-scope-debug loaded"); }catch(e){}

  function findBoxByTitle(title){
    const spans = document.querySelectorAll("button.btn-filter-box .characteristic-collapse-btn-inner");
    for(const s of spans){
      if(iwNormLabel(s.textContent) === title){
        const btn = s.closest("button.btn-filter-box");
        const targetSel = btn && btn.getAttribute("data-target");
        if(targetSel) return document.querySelector(targetSel);
      }
    }
    return null;
  }

  function getBrandFromUrl(){
    const path = (window.location.pathname || "").toLowerCase();

    const map = {
      "abarth":"Abarth",
      "alfa-romeo":"Alfa Romeo",
      "citroen":"Citroën",
      "ds":"DS",
      "fiat":"Fiat",
      "jeep":"Jeep",
      "lancia":"Lancia",
      "opel":"Opel",
      "peugeot":"Peugeot",
      "leapmotor":"Leapmotor"
    };

    // Automatische Fahrzeugmodell-Einschränkung NUR in echten Fahrzeugkategorien:
    // /abarth, /abarth-500-595, /citroen, /citroen-c3, /alfa-romeo-4c ...
    // NICHT über Breadcrumb/H1, weil Sammelseiten wie /mopar-shop sonst falsche Marken erkennen.
    const firstSeg = path.split("/").filter(Boolean)[0] || "";
    const slugs = Object.keys(map).sort((a,b)=> b.length - a.length);

    for(const slug of slugs){
      if(
        firstSeg === slug ||
        firstSeg.startsWith(slug + "-") ||
        firstSeg.startsWith(slug + "_")
      ){
        return map[slug];
      }
    }

    return "";
  }

  function getBrandFromMarkeFilterUrl(){
    const path = (window.location.pathname || "").toLowerCase();

    const map = {
      "abarth":"Abarth",
      "alfa-romeo":"Alfa Romeo",
      "alfaromeo":"Alfa Romeo",
      "citroen":"Citroën",
      "citroën":"Citroën",
      "ds":"DS",
      "fiat":"Fiat",
      "jeep":"Jeep",
      "lancia":"Lancia",
      "opel":"Opel",
      "peugeot":"Peugeot",
      "leapmotor":"Leapmotor"
    };

    // JTL: /mopar-shop__marke-alfaromeo, /alufelgen__marke-citroen, ...
    const m = path.match(/(?:^|__)marke-([^_\/]+)/);
    if(!m || !m[1]) return "";

    const raw = m[1];
    const compact = raw.replace(/-/g, "");

    if(map[raw]) return map[raw];
    if(map[compact]) return map[compact];

    return "";
  }

  // global für Mobile
  window.getSelectedBrandFacet = function getSelectedBrandFacet(){
    const box = findBoxByTitle("Fahrzeughersteller");

    if(box){
      const links = box.querySelectorAll("a.filter-item");
      for(const a of links){
        const checked = !!a.querySelector("i.fa-check-square, i.fas.fa-check-square, i.far.fa-check-square");
        const active = a.classList.contains("active") || a.getAttribute("aria-current")==="page";
        if(checked || active){
          const span = a.querySelector(".filter-item-value");
          const brand = iwNormLabel(span ? span.textContent : a.textContent);
          if(brand) return brand;
        }
      }
    }

    // Fallback: aktiver JTL-Merkmalfilter steckt zuverlässig in der URL.
    // Wichtig für Sammel-/Herstellerseiten wie /mopar-shop__marke-alfaromeo.
    return getBrandFromMarkeFilterUrl();
  };

  // global für Mobile + Debug
  window.getBrandFromUrl = getBrandFromUrl;
  window.getBrandFromMarkeFilterUrl = getBrandFromMarkeFilterUrl;

  function insertAfter(refNode, newNode){
    if(refNode && refNode.parentNode){
      refNode.parentNode.insertBefore(newNode, refNode.nextSibling);
    }
  }

  function applyModelFacet(){
    const modelBox = findBoxByTitle("Fahrzeugmodell");
    if(!modelBox) return;

    const facetBrand = window.getSelectedBrandFacet();
    const urlBrand   = getBrandFromUrl();
    const brand = facetBrand || urlBrand;

    window.IW_VEHICLE_FACETS_LAST_CONTEXT = {
      path: window.location.pathname,
      facetBrand,
      urlBrand,
      brand,
      source: "desktop"
    };

    const allLinks = Array.from(modelBox.querySelectorAll("a.filter-item"));
    if(!allLinks.length) return;

    allLinks.forEach(a => {
      a.style.display = "";
      const span = a.querySelector(".filter-item-value");
      if(span){
        if(!span.dataset.iwOriginalLabel) span.dataset.iwOriginalLabel = iwNormLabel(span.textContent);
        span.textContent = span.dataset.iwOriginalLabel;
      }
    });

    if(brand){
      const prefix = brand + " ";
      const visible = [];

      allLinks.forEach(a => {
        const span = a.querySelector(".filter-item-value");
        if(!span) return;
        const original = span.dataset.iwOriginalLabel || iwNormLabel(span.textContent);

        const ok = original.startsWith(prefix) || (brand==="Citroën" && original.startsWith("Citroen "));
        if(ok){
          span.textContent = stripPrefix(original, brand);
          a.style.display = "";
          a.classList.add("nav-link");
          visible.push(a);
        } else {
          a.style.display = "none";
        }
      });

      if(!visible.length) return;

      const searchWrapper = modelBox.querySelector(".filter-search-wrapper");
      let topWrap = modelBox.querySelector(".iw-facet-top-visible");
      if(topWrap) topWrap.remove();

      topWrap = document.createElement("div");
      topWrap.className = "iw-facet-top-visible nav flex-column";

      visible.forEach(a => topWrap.appendChild(a));
      if(searchWrapper){
        insertAfter(searchWrapper, topWrap);
      } else {
        modelBox.insertBefore(topWrap, modelBox.firstChild);
      }

      const navBlocks = modelBox.querySelectorAll(".nav.flex-column");
      navBlocks.forEach(nb => {
        if(nb.closest(".iw-facet-top-visible") || nb.closest(".iw-facet-groups")) return;
        nb.style.display = "none";
      });
      const showAll = modelBox.querySelector(".snippets-filter-show-all");
      if(showAll) showAll.style.display = "none";

      const groupsOld = modelBox.querySelector(".iw-facet-groups");
      if(groupsOld) groupsOld.remove();

      return;
    }

    const topOld = modelBox.querySelector(".iw-facet-top-visible");
    if(topOld) topOld.remove();

    const groupsOld = modelBox.querySelector(".iw-facet-groups");
    if(groupsOld) groupsOld.remove();

    const groups = new Map();
    const other = [];

    allLinks.forEach(a => {
      const span = a.querySelector(".filter-item-value");
      if(!span) return;
      const original = span.dataset.iwOriginalLabel || iwNormLabel(span.textContent);

      const b = getBrandFromPrefixedValue(original);
      if(b){
        if(!groups.has(b)) groups.set(b, []);
        groups.get(b).push(a);
        span.textContent = stripPrefix(original, b);
        a.classList.add("nav-link");
      } else {
        other.push(a);
        a.classList.add("nav-link");
      }
    });

    const wrap = document.createElement("div");
    wrap.className = "iw-facet-groups";

    function makeGroup(title, links){
      const g = document.createElement("div");
      g.className = "iw-facet-group";

      const h = document.createElement("div");
      h.className = "iw-facet-group-title";
      h.textContent = title;

      const items = document.createElement("div");
      items.className = "iw-facet-group-items nav flex-column";
      links.forEach(a => items.appendChild(a));

      g.appendChild(h);
      g.appendChild(items);
      return g;
    }

    IW_VEHICLE_BRANDS.forEach(b => { if(groups.has(b)) wrap.appendChild(makeGroup(b, groups.get(b))); });
    if(other.length) wrap.appendChild(makeGroup("Weitere", other));

    const searchWrapper = modelBox.querySelector(".filter-search-wrapper");
    if(searchWrapper){
      insertAfter(searchWrapper, wrap);
    } else {
      modelBox.insertBefore(wrap, modelBox.firstChild);
    }

    const navBlocks2 = modelBox.querySelectorAll(".nav.flex-column");
    navBlocks2.forEach(nb => {
      if(nb.closest(".iw-facet-top-visible") || nb.closest(".iw-facet-groups")) return;
      nb.style.display = "none";
    });
    const showAll2 = modelBox.querySelector(".snippets-filter-show-all");
    if(showAll2) showAll2.style.display = "none";
  }

  let scheduled = false;
  function run(){
    if(scheduled) return;
    scheduled = true;
    window.requestAnimationFrame(() => {
      scheduled = false;
      try{ applyModelFacet(); }catch(e){ try{ console.warn("IW vehicle facets error:", e); }catch(_){ } }
    });
  }

  function init(){
    run();

    const target =
      document.querySelector(".box-filter-characteristics") ||
      document.querySelector("#sidepanel_left") ||
      document.body;

    const obs = new MutationObserver(run);
    obs.observe(target, { childList:true, subtree:true });

    document.addEventListener("click", (e) => {
      const t = e.target;
      if(t && t.closest && t.closest(".box-filter-characteristics a.filter-item")){
        setTimeout(run, 40);
        setTimeout(run, 200);
      }
    }, true);

    setTimeout(run, 600);
  }

  if(document.readyState === "loading") document.addEventListener("DOMContentLoaded", init);
  else init();
})();

/* =========================================================
   IW Vehicle Facet Logic – Mobile
   ========================================================= */
function iwVehicleFacetsMobile(){
  try{ window.IW_VEHICLE_FACETS_MOBILE_VERSION = "v1-mobile"; }catch(e){}

  function findMobileBoxByTitle(title){
    const items = document.querySelectorAll("li.snippets-filter-mobile-item");
    for(const li of items){
      const span = li.querySelector("a[data-toggle=\"collapse\"] .characteristic-collapse-btn-inner");
      if(span && (span.textContent || "").trim() === title){
        return li;
      }
    }
    return null;
  }

  function applyMobileModelFacet(){
    const modelBox = findMobileBoxByTitle("Fahrzeugmodell");
    if(!modelBox) return;

    const facetBrand = window.getSelectedBrandFacet ? window.getSelectedBrandFacet() : "";
    const urlBrand   = window.getBrandFromUrl ? window.getBrandFromUrl() : "";
    const brand = facetBrand || urlBrand;

    window.IW_VEHICLE_FACETS_LAST_CONTEXT_MOBILE = {
      path: window.location.pathname,
      facetBrand,
      urlBrand,
      brand,
      source: "mobile"
    };

    const collapse = modelBox.querySelector(".snippets-filter-mobile-item-collapse");
    if(!collapse) return;

    const allLinks = Array.from(collapse.querySelectorAll("a.filter-item"));
    if(!allLinks.length) return;

    allLinks.forEach(a => {
      a.style.display = "";
      const span = a.querySelector(".filter-item-value");
      if(span){
        if(!span.dataset.iwOriginalLabel) span.dataset.iwOriginalLabel = iwNormLabel(span.textContent);
        span.textContent = span.dataset.iwOriginalLabel;
      }
    });

    if(brand){
      const prefix = brand + " ";
      const visible = [];

      allLinks.forEach(a => {
        const span = a.querySelector(".filter-item-value");
        if(!span) return;
        const original = span.dataset.iwOriginalLabel || iwNormLabel(span.textContent);

        const ok = original.startsWith(prefix) || (brand === "Citroën" && original.startsWith("Citroen "));
        if(ok){
          span.textContent = stripPrefix(original, brand);
          a.style.display = "";
          visible.push(a);
        }else{
          a.style.display = "none";
        }
      });

      if(!visible.length) return;

      const searchWrapper = collapse.querySelector(".filter-search-wrapper");
      let topWrap = collapse.querySelector(".iw-facet-top-visible-mobile");
      if(topWrap) topWrap.remove();

      topWrap = document.createElement("div");
      topWrap.className = "iw-facet-top-visible-mobile nav flex-column";
      visible.forEach(a => topWrap.appendChild(a));

      if(searchWrapper){
        if(searchWrapper.nextSibling){
          searchWrapper.parentNode.insertBefore(topWrap, searchWrapper.nextSibling);
        } else {
          searchWrapper.parentNode.appendChild(topWrap);
        }
      } else {
        collapse.insertBefore(topWrap, collapse.firstChild);
      }

      const navs = collapse.querySelectorAll(".nav.flex-column");
      navs.forEach(nb => {
        if(nb.closest(".iw-facet-top-visible-mobile") || nb.closest(".iw-facet-groups-mobile")) return;
        nb.style.display = "none";
      });
      const showAll = collapse.querySelector(".snippets-filter-show-all");
      if(showAll) showAll.style.display = "none";

      const groupsOld = collapse.querySelector(".iw-facet-groups-mobile");
      if(groupsOld) groupsOld.remove();

      return;
    }

    const oldTop = collapse.querySelector(".iw-facet-top-visible-mobile");
    if(oldTop) oldTop.remove();
    const oldGroups = collapse.querySelector(".iw-facet-groups-mobile");
    if(oldGroups) oldGroups.remove();

    const groups = new Map();
    const other = [];

    allLinks.forEach(a => {
      const span = a.querySelector(".filter-item-value");
      if(!span) return;
      const original = span.dataset.iwOriginalLabel || iwNormLabel(span.textContent);

      const b = getBrandFromPrefixedValue(original);
      if(b){
        if(!groups.has(b)) groups.set(b, []);
        groups.get(b).push(a);
        span.textContent = stripPrefix(original, b);
      }else{
        other.push(a);
      }
    });

    const wrap = document.createElement("div");
    wrap.className = "iw-facet-groups-mobile";

    function makeGroup(title, links){
      const g = document.createElement("div");
      g.className = "iw-facet-group";

      const h = document.createElement("div");
      h.className = "iw-facet-group-title";
      h.textContent = title;

      const items = document.createElement("div");
      items.className = "iw-facet-group-items nav flex-column";
      links.forEach(a => items.appendChild(a));

      g.appendChild(h);
      g.appendChild(items);
      return g;
    }

    IW_VEHICLE_BRANDS.forEach(b => { if(groups.has(b)) wrap.appendChild(makeGroup(b, groups.get(b))); });
    if(other.length) wrap.appendChild(makeGroup("Weitere", other));

    const searchWrapper2 = collapse.querySelector(".filter-search-wrapper");
    if(searchWrapper2){
      if(searchWrapper2.nextSibling){
        searchWrapper2.parentNode.insertBefore(wrap, searchWrapper2.nextSibling);
      } else {
        searchWrapper2.parentNode.appendChild(wrap);
      }
    } else {
      collapse.insertBefore(wrap, collapse.firstChild);
    }

    const navs2 = collapse.querySelectorAll(".nav.flex-column");
    navs2.forEach(nb => {
      if(nb.closest(".iw-facet-top-visible-mobile") || nb.closest(".iw-facet-groups-mobile")) return;
      nb.style.display = "none";
    });
    const showAll2 = collapse.querySelector(".snippets-filter-show-all");
    if(showAll2) showAll2.style.display = "none";
  }

  let scheduled = false;
  function runMobile(){
    if(scheduled) return;
    scheduled = true;
    window.requestAnimationFrame(() => {
      scheduled = false;
      try{ applyMobileModelFacet(); }catch(e){ try{ console.warn("IW vehicle facets mobile error:", e); }catch(_){ } }
    });
  }

  function initMobile(){
    runMobile();
    const target = document.querySelector("#sidepanelleft") || document.body;
    const obs = new MutationObserver(runMobile);
    obs.observe(target, { childList:true, subtree:true });

    document.addEventListener("click", (e) => {
      const t = e.target;
      if(t && t.closest && t.closest("li.snippets-filter-mobile-item a.filter-item")){
        setTimeout(runMobile, 40);
        setTimeout(runMobile, 200);
      }
    }, true);

    setTimeout(runMobile, 600);
  }

  if(document.readyState === "loading") document.addEventListener("DOMContentLoaded", initMobile);
  else initMobile();
}

if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", iwVehicleFacetsMobile);
} else {
  iwVehicleFacetsMobile();
}

/* =========================================================
   IW: Merkmalfilter "Fahrzeughersteller" nur in echten Fahrzeugkategorien ausblenden
   - Ausblenden nur, wenn der ERSTE URL-Slug eine Fahrzeugmarke ist oder mit ihr beginnt:
     /abarth, /abarth-500-595, /citroen, /citroen-c3, ...
   - NICHT ausblenden auf Sammel-/Herstellerseiten: /mopar-shop, /fanartikel, /alufelgen, ...
   - NICHT ausblenden, wenn aktiv __marke-xyz gewählt wurde, damit der Kunde die Marke wechseln kann.
   ========================================================= */
(function iwHideVehicleBrandFilterInVehicleCategories(){
  window.IW_VEHICLE_BRAND_FILTER_VISIBILITY_VERSION = "v5-vehicle-category-only-debug";

  const FILTER_TITLE = "Fahrzeughersteller";
  const BRAND_SLUGS = ["alfa-romeo","leapmotor","abarth","citroen","fiat","jeep","lancia","opel","peugeot","ds"];

  function norm(s){
    return (s || "")
      .toString()
      .replace(/[\u200B-\u200D\uFEFF]/g, "")
      .replace(/[\u00A0\u202F]/g, " ")
      .replace(/\s+/g, " ")
      .trim();
  }

  function hasActiveMarkeFilter(){
    const path = (window.location.pathname || "").toLowerCase();
    return /(?:^|__)marke-[^_\/]+/.test(path);
  }

  function isVehicleCategoryPath(){
    const path = (window.location.pathname || "").toLowerCase();
    const firstSeg = path.split("/").filter(Boolean)[0] || "";

    return BRAND_SLUGS.some(slug =>
      firstSeg === slug ||
      firstSeg.startsWith(slug + "-") ||
      firstSeg.startsWith(slug + "_")
    );
  }

  function shouldHide(){
    return isVehicleCategoryPath() && !hasActiveMarkeFilter();
  }

  function installCss(){
    if(document.getElementById("iw-hide-vehiclebrand-filter-css")) return;

    const style = document.createElement("style");
    style.id = "iw-hide-vehiclebrand-filter-css";
    style.textContent = `.iw-hidden-vehiclebrand-filter{display:none !important;}`;
    document.head.appendChild(style);
  }

  function setVisible(el, visible){
    if(!el) return;
    el.classList.toggle("iw-hidden-vehiclebrand-filter", !visible);
    el.style.display = visible ? "" : "none";
  }

  function applyDesktop(visible){
    document.querySelectorAll("button.btn-filter-box .characteristic-collapse-btn-inner").forEach(span => {
      if(norm(span.textContent) !== FILTER_TITLE) return;

      const btn = span.closest("button.btn-filter-box");
      if(!btn) return;

      setVisible(btn, visible);

      const targetSel = btn.getAttribute("data-target");
      const collapse = targetSel ? document.querySelector(targetSel) : null;
      setVisible(collapse, visible);

      if(collapse){
        let next = collapse.nextElementSibling;
        while(next && next.nodeType === 1){
          if(next.classList && next.classList.contains("box-filter-hr")){
            setVisible(next, visible);
            break;
          }
          if(next.matches && (next.matches("button.btn-filter-box") || next.matches(".collapse"))) break;
          next = next.nextElementSibling;
        }
      }
    });
  }

  function applyMobile(visible){
    document.querySelectorAll("li.snippets-filter-mobile-item").forEach(li => {
      const titleSpan = li.querySelector(".characteristic-collapse-btn-inner");
      const target = li.querySelector('#filter-collapse-Fahrzeughersteller, [data-target="#filter-collapse-Fahrzeughersteller"]');
      const search = li.querySelector('input[placeholder*="Fahrzeughersteller"], input[aria-label*="Fahrzeughersteller"]');

      if((titleSpan && norm(titleSpan.textContent) === FILTER_TITLE) || target || search){
        setVisible(li, visible);
      }
    });

    const collapse = document.querySelector("#filter-collapse-Fahrzeughersteller");
    if(collapse){
      const li = collapse.closest("li.snippets-filter-mobile-item");
      setVisible(li || collapse, visible);
    }
  }

  let scheduled = false;
  function run(){
    if(scheduled) return;
    scheduled = true;

    window.requestAnimationFrame(() => {
      scheduled = false;
      installCss();

      const hide = shouldHide();
      const visible = !hide;

      applyDesktop(visible);
      applyMobile(visible);

      window.IW_VEHICLE_BRAND_FILTER_VISIBILITY_STATE = {
        visible,
        hide,
        path: window.location.pathname,
        isVehicleCategoryPath: isVehicleCategoryPath(),
        hasActiveMarkeFilter: hasActiveMarkeFilter(),
        version: window.IW_VEHICLE_BRAND_FILTER_VISIBILITY_VERSION
      };
    });
  }

  function pollRun(durationMs){
    const started = Date.now();
    const timer = setInterval(() => {
      run();
      if(Date.now() - started >= durationMs) clearInterval(timer);
    }, 150);
  }

  function init(){
    run();

    const obs = new MutationObserver(run);
    obs.observe(document.body, { childList:true, subtree:true });

    document.addEventListener("click", (e) => {
      const t = e.target;
      if(!t || !t.closest) return;

      if(t.closest("#js-filters") || t.closest('[data-target="#collapseFilter"]')){
        pollRun(1500);
      }

      if(t.closest("a.filter-item") || t.closest(".snippets-filter-show-all") || t.closest("[data-target]")){
        setTimeout(run, 80);
        setTimeout(run, 350);
        setTimeout(run, 900);
      }
    }, true);

    pollRun(1200);
  }

  if(document.readyState === "loading"){
    document.addEventListener("DOMContentLoaded", init);
  } else {
    init();
  }
})();
