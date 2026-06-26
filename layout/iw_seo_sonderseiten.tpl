{* ============================================================
   IW: SEO-Titel und Beschreibungen für Sonderseiten
   ============================================================
   Editierbar direkt im JTL Admin:
   Design → Template-Editor → NOVAChild → layout → iw_seo_sonderseiten.tpl

   Nur meta_title und meta_description anpassen.
   Keine anderen Zeilen verändern.

   scope='parent' ist zwingend: Ohne es wirkt {assign} nur
   innerhalb dieses Includes, nicht im aufrufenden Template.
   ============================================================ *}

{if $smarty.server.REQUEST_URI|strstr:'sonderangebote'}

    {assign var='meta_title'
            value='Sonderangebote – Abarth Opel Alfa Romeo Jeep Peugeot Fiat Zubehör & Tuning günstig kaufen | Italo-Welt'
            scope='parent'}

    {assign var='meta_description'
            value='Aktuelle Sonderangebote für Abarth, Alfa Romeo, Fiat, Jeep, Opel & Peugeot ✔ Mopar Original & Zubehör ✔ Günstig kaufen | Italo-Welt'
            scope='parent'}

{elseif $smarty.server.REQUEST_URI|strstr:'neu-am-start'}

    {assign var='meta_title'
            value='Neu im Sortiment – Abarth Opel Alfa Romeo Jeep Peugeot Fiat Zubehör & Tuning Artikel | Italo-Welt'
            scope='parent'}

    {assign var='meta_description'
            value='Neue Artikel für Abarth, Alfa Romeo, Fiat, Jeep, Opel & Peugeot ✔ Mopar Original & Zubehör ✔ Jetzt entdecken | Italo-Welt'
            scope='parent'}

{/if}
