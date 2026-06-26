{block name='productdetails-price'}
    {if $Artikel->Preise !== null && $smarty.session.Kundengruppe->mayViewPrices()}
        <div class="price_wrapper">
            {block name='productdetails-price-wrapper'}
            {if $Artikel->getOption('nShowOnlyOnSEORequest', 0) === 1}
                {block name='productdetails-price-out-of-stock'}
                    <span class="price_label price_out_of_stock">{lang key='productOutOfStock' section='productDetails'}</span>
                    {block name='productdetails-price-out-of-stock-microdata'}
                        {if !($Artikel->Preise->fVKNetto == 0 && $Einstellungen.global.global_preis0 === 'N')}
                            <span itemprop="priceSpecification" itemscope itemtype="https://schema.org/UnitPriceSpecification">
                                {if $Artikel->Preise->oPriceRange->isRange()}
                                    <meta itemprop="minPrice" content="{$Artikel->Preise->oPriceRange->getMinLocalized($NettoPreise)|formatForMicrodata}">
                                    <meta itemprop="maxPrice" content="{$Artikel->Preise->oPriceRange->getMaxLocalized($NettoPreise)|formatForMicrodata}">
                                {/if}
                                <meta itemprop="price" content="{$Artikel->Preise->cVKLocalized[$NettoPreise]|formatForMicrodata}">
                                <meta itemprop="priceCurrency" content="{JTL\Session\Frontend::getCurrency()->getName()}">
                                {if $Artikel->Preise->Sonderpreis_aktiv && $Artikel->dSonderpreisStart_en !== null && $Artikel->dSonderpreisEnde_en !== null}
                                    <meta itemprop="validFrom" content="{$Artikel->dSonderpreisStart_en}">
                                    <meta itemprop="validThrough" content="{$Artikel->dSonderpreisEnde_en}">
                                    <meta itemprop="priceValidUntil" content="{$Artikel->dSonderpreisEnde_en}">
                                {/if}
                                {if !empty($Artikel->cLocalizedVPE)}
                                    <span itemprop="priceSpecification" itemscope itemtype="https://schema.org/UnitPriceSpecification">
                                        <meta itemprop="price" content="{if $Artikel->Preise->oPriceRange->isRange()}{($Artikel->Preise->oPriceRange->getMinLocalized($NettoPreise)|formatForMicrodata/$Artikel->fVPEWert)|string_format:"%.2f"}{else}{($Artikel->Preise->cVKLocalized[$NettoPreise]|formatForMicrodata/$Artikel->fVPEWert)|string_format:"%.2f"}{/if}">
                                        <meta itemprop="priceCurrency" content="{JTL\Session\Frontend::getCurrency()->getName()}">
                                        <span itemprop="referenceQuantity" itemscope itemtype="https://schema.org/QuantitativeValue">
                                            <meta itemprop="price" content="{$Artikel->cLocalizedVPE[$NettoPreise]}">
                                            <meta itemprop="value" content="{$Artikel->fGrundpreisMenge}">
                                            <meta itemprop="unitText" content="{$Artikel->cVPEEinheit|regex_replace:"/[\\d ]/":""}">
                                        </span>
                                    </span>
                                {/if}
                            </span>
                        {/if}
                    {/block}
                {/block}
            {elseif $Artikel->Preise->fVKNetto == 0 && $Artikel->bHasKonfig}
                {block name='productdetails-price-as-configured'}
                    <span class="price_label price_as_configured">{lang key='priceAsConfigured' section='productDetails'}</span> <span class="price"></span>
                {/block}
            {elseif $Artikel->Preise->fVKNetto == 0 && $Einstellungen.global.global_preis0 === 'N'}
                {block name='productdetails-price-on-application'}
                    <span class="price_label price_on_application">{lang key='priceOnApplication'}</span>
                {/block}
            {else}
                {block name='productdetails-price-label'}
                    {if ($tplscope !== 'detail' && $Artikel->Preise->oPriceRange->isRange() && $Artikel->Preise->oPriceRange->rangeWidth() > $Einstellungen.artikeluebersicht.articleoverview_pricerange_width)
                    || ($tplscope === 'detail' && ($Artikel->nVariationsAufpreisVorhanden == 1 || $Artikel->bHasKonfig) && $Artikel->kVaterArtikel == 0)}
                    <span class="price_label pricestarting">{lang key='priceStarting'} </span>
                    {elseif $Artikel->Preise->rabatt > 0}
                        <span class="price_label nowonly">{lang key='nowOnly'} </span>
                    {/if}
                {/block}
                {if $tplscope === 'detail'}
                    <div class="iw-price-inline-row">
                {/if}
                <div class="price {if $priceLarge|default:false}h1{else}productbox-price{/if} {if isset($Artikel->Preise->Sonderpreis_aktiv) && $Artikel->Preise->Sonderpreis_aktiv} special-price{/if}">
                    {block name='productdetails-range'}
                        <span{if $Artikel->Preise->oPriceRange->isRange() && $tplscope !== 'box'} itemprop="priceSpecification" itemscope itemtype="https://schema.org/UnitPriceSpecification"{/if}>
                        {if $tplscope !== 'detail' && $Artikel->Preise->oPriceRange->isRange()}
                            {if $Artikel->Preise->oPriceRange->rangeWidth() <= $Einstellungen.artikeluebersicht.articleoverview_pricerange_width}
                                {assign var=rangePrices value=$Artikel->Preise->oPriceRange->getLocalizedArray($NettoPreise)}
                                <span class="first-range-price">{$rangePrices[0]} - </span><span class="second-range-price">{$rangePrices[1]} {if $tplscope !== 'detail'} <span class="footnote-reference">*</span>{/if}</span>
                            {else}
                                {$Artikel->Preise->oPriceRange->getMinLocalized($NettoPreise)} <span class="footnote-reference">*</span>
                            {/if}
                        {else}
                            {if $Artikel->Preise->oPriceRange->isRange() && ($Artikel->nVariationsAufpreisVorhanden == 1 || $Artikel->bHasKonfig) && $Artikel->kVaterArtikel == 0}{$Artikel->Preise->oPriceRange->getMinLocalized($NettoPreise)}{else}{$Artikel->Preise->cVKLocalized[$NettoPreise]}{/if}
                        {/if}
                        {if $tplscope !== 'detail' && !$Artikel->Preise->oPriceRange->isRange()} <span class="footnote-reference">*</span>{/if}
                        </span>
                    {/block}
                </div>
                {if $tplscope === 'detail'}
                    {* Referenzpreis für Detailseite:
                       UVP hat Vorrang vor altem VK/Sonderpreis-Streichpreis.
                       Wichtig: bewusst NICHT an die Backend-Option "UVP anzeigen" gekoppelt,
                       weil der Inline-Preisblock die konsistente Rabattbasis braucht. *}
                    {assign var=iwShowOldPrice value=false}
                    {assign var=iwHasUVP value=false}
                    {* UVP nur anzeigen wenn er auch wirklich ÜBER dem Kaufpreis liegt *}
                    {if $Artikel->fUVP > 0 && $Artikel->Preise->fVKBrutto < $Artikel->fUVP}
                        {assign var=iwHasUVP value=true}
                    {/if}

                    {block name='productdetails-price-special-prices-detail'}
                    {if $Artikel->Preise->Sonderpreis_aktiv && $Einstellungen.artikeldetails.artikeldetails_sonderpreisanzeige == 2}
                        {assign var=iwShowOldPrice value=true}
                            {if $iwHasUVP}
                                <span class="iw-uvp-inline">{lang key='suggestedPrice' section='productDetails'}: <del class="value">{$Artikel->getUVPLocalized($NettoPreise)}</del></span>
                            {else}
                                <span class="iw-old-price-inline">{lang key='oldPrice'}: <del class="value">{$Artikel->Preise->alterVKLocalized[$NettoPreise]}</del></span>
                            {/if}
                            {assign var=iwPercent value=0}
                            {if isset($Artikel->SieSparenX) && $Artikel->SieSparenX->anzeigen == 1 && $Artikel->SieSparenX->nProzent > 0 && !$NettoPreise && $Artikel->taxData['tax'] > 0}
                                {assign var=iwPercent value=$Artikel->SieSparenX->nProzent}
                            {elseif isset($Artikel->Preise) && $Artikel->Preise->rabatt > 0}
                                {assign var=iwPercent value=$Artikel->Preise->rabatt}
                            {/if}
                            {if $iwPercent > 0}
                                <span class="iw-discount-badge" title="{lang key='youSave' section='productDetails'} {$iwPercent|round:0}%">-{$iwPercent|round:0}%</span>
                            {/if}
                    {elseif !$Artikel->Preise->Sonderpreis_aktiv && $Artikel->Preise->rabatt > 0 && ($Einstellungen.artikeldetails.artikeldetails_rabattanzeige == 3 || $Einstellungen.artikeldetails.artikeldetails_rabattanzeige == 4)}
                        {assign var=iwShowOldPrice value=true}
                            {if $iwHasUVP}
                                <span class="iw-uvp-inline">{lang key='suggestedPrice' section='productDetails'}: <del class="value">{$Artikel->getUVPLocalized($NettoPreise)}</del></span>
                            {else}
                                <span class="iw-old-price-inline">{lang key='oldPrice'}: <del class="value">{$Artikel->Preise->alterVKLocalized[$NettoPreise]}</del></span>
                            {/if}
                            {assign var=iwPercent value=0}
                            {if isset($Artikel->SieSparenX) && $Artikel->SieSparenX->anzeigen == 1 && $Artikel->SieSparenX->nProzent > 0 && !$NettoPreise && $Artikel->taxData['tax'] > 0}
                                {assign var=iwPercent value=$Artikel->SieSparenX->nProzent}
                            {elseif isset($Artikel->Preise) && $Artikel->Preise->rabatt > 0}
                                {assign var=iwPercent value=$Artikel->Preise->rabatt}
                            {/if}
                            {if $iwPercent > 0}
                                <span class="iw-discount-badge" title="{lang key='youSave' section='productDetails'} {$iwPercent|round:0}%">-{$iwPercent|round:0}%</span>
                            {/if}
                    {/if}
                    {/block}

                    {if !$iwShowOldPrice && $iwHasUVP}
                        {block name='productdetails-price-uvp'}
                            <span class="iw-uvp-inline">{lang key='suggestedPrice' section='productDetails'}: <del class="value">{$Artikel->getUVPLocalized($NettoPreise)}</del></span>
                        {/block}
                        {assign var=iwPercent value=0}
                        {if isset($Artikel->SieSparenX) && $Artikel->SieSparenX->anzeigen == 1 && $Artikel->SieSparenX->nProzent > 0 && !$NettoPreise && $Artikel->taxData['tax'] > 0}
                            {assign var=iwPercent value=$Artikel->SieSparenX->nProzent}
                        {elseif isset($Artikel->Preise) && $Artikel->Preise->rabatt > 0}
                            {assign var=iwPercent value=$Artikel->Preise->rabatt}
                        {/if}
                        {if $iwPercent > 0}
                            <span class="iw-discount-badge" title="{lang key='youSave' section='productDetails'} {$iwPercent|round:0}%">-{$iwPercent|round:0}%</span>
                        {/if}
                    {/if}
                    </div>
                {/if}
                {block name='productdetails-price-snippets'}
                    {if $tplscope !== 'box'}
                        {if $Artikel->Preise->oPriceRange->isRange()}
                            <meta itemprop="minPrice" content="{$Artikel->Preise->oPriceRange->getMinLocalized($NettoPreise)|formatForMicrodata}">
                            <meta itemprop="maxPrice" content="{$Artikel->Preise->oPriceRange->getMaxLocalized($NettoPreise)|formatForMicrodata}">
                        {/if}
                        <meta itemprop="price" content="{$Artikel->Preise->cVKLocalized[$NettoPreise]|formatForMicrodata}">
                        <meta itemprop="priceCurrency" content="{JTL\Session\Frontend::getCurrency()->getName()}">
                        {if $Artikel->Preise->Sonderpreis_aktiv && $Artikel->dSonderpreisStart_en !== null && $Artikel->dSonderpreisEnde_en !== null}
                            <meta itemprop="validFrom" content="{$Artikel->dSonderpreisStart_en}">
                            <meta itemprop="validThrough" content="{$Artikel->dSonderpreisEnde_en}">
                            <meta itemprop="priceValidUntil" content="{$Artikel->dSonderpreisEnde_en}">
                        {/if}
                    {/if}
                {/block}
                {if $tplscope === 'detail'}
                    {block name='productdetails-price-detail'}
                        <div class="price-note">
                            {if $Artikel->cEinheit && ($Artikel->fMindestbestellmenge > 1 || $Artikel->fAbnahmeintervall > 1)}
                                {block name='productdetails-price-label-per-unit'}
                                    <span class="price_label per_unit"> {lang key='vpePer'} 1 {$Artikel->cEinheit}</span>
                                {/block}
                            {/if}

                            {* Grundpreis *}
                            {if !empty($Artikel->cLocalizedVPE)}
                                {block name='productdetails-price-detail-base-price'}
                                    <div class="base-price text-nowrap-util" itemprop="priceSpecification" itemscope itemtype="https://schema.org/UnitPriceSpecification">
                                        <meta itemprop="price" content="{if $Artikel->Preise->oPriceRange->isRange()}{($Artikel->Preise->oPriceRange->getMinLocalized($NettoPreise)|formatForMicrodata/$Artikel->fVPEWert)|string_format:"%.2f"}{else}{($Artikel->Preise->cVKLocalized[$NettoPreise]|formatForMicrodata/$Artikel->fVPEWert)|string_format:"%.2f"}{/if}">
                                        <meta itemprop="priceCurrency" content="{JTL\Session\Frontend::getCurrency()->getName()}">
                                        <span class="value" itemprop="referenceQuantity" itemscope itemtype="https://schema.org/QuantitativeValue">
                                            {$Artikel->cLocalizedVPE[$NettoPreise]}
                                            <meta itemprop="value" content="{$Artikel->fGrundpreisMenge}">
                                            <meta itemprop="unitText" content="{$Artikel->cVPEEinheit|regex_replace:"/[\\d ]/":""}">
                                        </span>
                                    </div>
                                {/block}
                            {/if}

                            {block name='productdetails-price-savings-detail'}
                                {* Savings line removed: replaced by percent badge in price row *}
                            {/block}

                            {block name='productdetails-price-detail-vat-info'}
                                <span class="vat_info">
                                    {* Output aus shipping_tax_info.tpl abfangen, damit das Leerzeichen nach "Versand"
                                       nicht innerhalb des <a>-Links hängt (sonst ist "Versand " klickbar).
                                       Wir entfernen beliebige Whitespaces/&nbsp; direkt vor </a>.
                                    *}
                                    {capture assign='iwVatShipInfo'}{include file='snippets/shipping_tax_info.tpl' taxdata=$Artikel->taxData}{/capture}
                                    {* Smarty stolpert über \x{00A0} wegen der geschweiften Klammern.
                                       In der Praxis reicht es, &nbsp; und normale Whitespaces direkt vor </a> zu entfernen.
                                    *}
                                    {assign var='iwVatShipInfo' value=$iwVatShipInfo|regex_replace:"/(<a[^>]*>[^<]*?)(?:&nbsp;|\\s)+<\\/a>/u":"\\1</a>"}
                                    {$iwVatShipInfo nofilter}

                                    {* JTL-Shop 5.4+: Versandklasse wieder hinter "zzgl. Versand" anzeigen (SHOP-5426)
                                       JTL hat die Backend-Option entfernt, das DB-Feld bleibt aber: tversandklasse.
                                       Wir holen die Versandklasse des Artikels und hängen sie an die Preisinfo an.
                                    *}
                                    {assign var=iwVersandklasseName value=''}
                                    {assign var=iwVersandklasseID value=0}

                                    {* 1) Wenn kVersandklasse im Artikelobjekt vorhanden ist: direkt nutzen *}
                                    {if isset($Artikel->kVersandklasse) && $Artikel->kVersandklasse|@intval > 0}
                                        {assign var=iwVersandklasseID value=$Artikel->kVersandklasse|@intval}
                                    {elseif isset($Artikel->kArtikel) && $Artikel->kArtikel|@intval > 0}
                                        {* 2) Fallback: Versandklasse aus tartikel holen *}
                                        {assign var=iwArtikelRow value=JTL\Shop::Container()->getDB()->selectSingleRow('tartikel', 'kArtikel', $Artikel->kArtikel|@intval)}
                                        {* selectSingleRow() liefert stdClass -> in Smarty daher unbedingt mit -> zugreifen *}
                                        {if $iwArtikelRow && isset($iwArtikelRow->kVersandklasse) && $iwArtikelRow->kVersandklasse|@intval > 0}
                                            {assign var=iwVersandklasseID value=$iwArtikelRow->kVersandklasse|@intval}
                                        {/if}
                                    {/if}

                                    {* 3) Versandklassen-Name (interner Bezeichner) laden *}
                                    {if $iwVersandklasseID > 0}
                                        {assign var=iwVersandklasseRow value=JTL\Shop::Container()->getDB()->selectSingleRow('tversandklasse', 'kVersandklasse', $iwVersandklasseID)}
                                        {* selectSingleRow() liefert stdClass -> in Smarty daher unbedingt mit -> zugreifen *}
                                        {if $iwVersandklasseRow && !empty($iwVersandklasseRow->cName)}
                                            {assign var=iwVersandklasseName value=$iwVersandklasseRow->cName}
                                        {/if}
                                    {/if}

                                    {* Ausgabe: "(Spedition)" etc. *}
                                    {if !empty($iwVersandklasseName)}
                                        <span class="iw-shipping-class"> ({$iwVersandklasseName|escape:'html'})</span>
                                    {/if}
                                </span>
                            {/block}

                            {block name='productdetails-price-min-value-info'}
                                {$minOrderValue = $smarty.session.Kundengruppe->getAttribute('mindestbestellwert')}
                                {if $minOrderValue > 0}
                                    {if $Artikel->Preise->oPriceRange->isRange() && ($Artikel->nVariationsAufpreisVorhanden == 1 || $Artikel->bHasKonfig) && $Artikel->kVaterArtikel == 0}
                                        {if $NettoPreise == 1}
                                            {$minPrice = $Artikel->Preise->oPriceRange->minNettoPrice}
                                        {else}
                                            {$minPrice = $Artikel->Preise->oPriceRange->minBruttoPrice}
                                        {/if}
                                    {else}
                                        {$minPrice = $Artikel->Preise->fVK[$NettoPreise]}
                                    {/if}

                                    {if $minOrderValue > $minPrice}
                                        <div class="min-value-wrapper">{lang key='minValueInfo' section='productDetails' printf=$minOrderValue|cat:':::'|cat:$smarty.session.Waehrung->getName()}</div>
                                    {/if}
                                {/if}
                            {/block}

                            {block name='productdetails-price-discount-detail'}
                                {if !$Artikel->Preise->Sonderpreis_aktiv && $Artikel->Preise->rabatt > 0 && ($Einstellungen.artikeldetails.artikeldetails_rabattanzeige == 2 || $Einstellungen.artikeldetails.artikeldetails_rabattanzeige == 4)}
                                    <div class="discount">{lang key='discount'}: <span class="value text-nowrap-util">{$Artikel->Preise->rabatt}%</span></div>
                                {/if}
                            {/block}

                            {* --- Staffelpreise? --- *}
                            {if !empty($Artikel->staffelPreis_arr)}
                                {block name='productdetails-price-detail-bulk-price'}
                                    <div class="bulk-prices">
                                        <table class="table table-sm table-hover">
                                            <thead>
                                                {block name='productdetails-price-detail-bulk-price-head'}
                                                    <tr>
                                                        <th>
                                                            {lang key='fromDifferential' section='productOverview'}
                                                        </th>
                                                        <th>{lang key='pricePerUnit' section='productDetails'}{if $Artikel->cEinheit} / {$Artikel->cEinheit}{/if}
                                                            {if isset($Artikel->cMasseinheitName) && isset($Artikel->fMassMenge) && $Artikel->fMassMenge > 0 && $Artikel->cTeilbar !== 'Y' && ($Artikel->fAbnahmeintervall == 0 || $Artikel->fAbnahmeintervall == 1) && isset($Artikel->cMassMenge)}
                                                                ({$Artikel->cMassMenge} {$Artikel->cMasseinheitName})
                                                            {/if}
                                                        </th>
                                                        {if !empty($Artikel->staffelPreis_arr[0].cBasePriceLocalized)}
                                                        <th>
                                                            {lang key='basePrice'}
                                                        </th>
                                                        {/if}
                                                    </tr>
                                                {/block}
                                            </thead>
                                            <tbody>
                                                {block name='productdetails-price-detail-bulk-price-body'}
                                                    {foreach $Artikel->staffelPreis_arr as $bulkPrice}
                                                        {if $bulkPrice.nAnzahl > 0}
                                                            <tr class="bulk-price-{$bulkPrice.nAnzahl}">
                                                                <td>{$bulkPrice.nAnzahl}</td>
                                                                <td>
                                                                    <span class="bulk-price">{$bulkPrice.cPreisLocalized[$NettoPreise]}</span><span class="footnote-reference">*</span>
                                                                </td>
                                                                {if !empty($bulkPrice.cBasePriceLocalized)}
                                                                    <td class="bulk-base-price">
                                                                        {$bulkPrice.cBasePriceLocalized[$NettoPreise]}
                                                                    </td>
                                                                {/if}
                                                            </tr>
                                                        {/if}
                                                    {/foreach}
                                                {/block}
                                            </tbody>
                                        </table>
                                    </div>{* /bulk-price *}
                                {/block}
                            {/if}
                        </div>{* /price-note *}
                    {/block}
                {else}{* scope productlist *}
                    {block name='productdetails-price-price-note'}
                    <div class="price-note">
                        {* Grundpreis *}
                        {if !empty($Artikel->cLocalizedVPE)}
                            {block name='productdetails-price-list-base-price'}
                                <div class="base_price" itemprop="priceSpecification" itemscope itemtype="https://schema.org/UnitPriceSpecification">
                                    <meta itemprop="price" content="{($Artikel->Preise->oPriceRange->getMinLocalized($NettoPreise)|formatForMicrodata/$Artikel->fVPEWert)|string_format:"%.2f"}">
                                    <meta itemprop="priceCurrency" content="{JTL\Session\Frontend::getCurrency()->getName()}">
                                    <span class="value" itemprop="referenceQuantity" itemscope itemtype="https://schema.org/QuantitativeValue">
                                        {$Artikel->cLocalizedVPE[$NettoPreise]}
                                        {if ($Artikel->Preise->oPriceRange->isRange() === true)
                                            && !(!empty($hasOnlyListableVariations)
                                                 && empty($Artikel->FunktionsAttribute[\FKT_ATTRIBUT_NO_GAL_VAR_PREVIEW]))
                                        }
                                            <br>
                                            {lang section='productOverview' key='moreVariationsAvailable'}
                                        {/if}
                                        <meta itemprop="value" content="{$Artikel->fGrundpreisMenge}">
                                        <meta itemprop="unitText" content="{$Artikel->cVPEEinheit|regex_replace:"/[\\d ]/":""}">
                                    </span>
                                </div>
                            {/block}
                        {/if}
                        {block name='productdetails-price-special-prices'}
                            {* IW Listing: nur durchgestrichener Streichpreis, KEIN Label.
                               Auf der Liste kann nicht gekauft werden -> kein rechtliches Risiko,
                               die genaue Referenz (UVP/alter Preis) steht auf der Produktdetailseite.
                               Streichpreis = UVP wenn über Kaufpreis, sonst alterVKLocalized. *}
                            {assign var=iwListingUvp value=$Artikel->Preise->fUVPBrutto|default:0}
                            {if $iwListingUvp < 0.01 && $Artikel->fUVP > 0}
                                {assign var=iwListingUvp value=$Artikel->fUVP}
                            {/if}
                            {assign var=iwListingHasUvp value=false}
                            {if $iwListingUvp > 0 && $Artikel->Preise->fVKBrutto < $iwListingUvp}
                                {assign var=iwListingHasUvp value=true}
                            {/if}
                            {if $Artikel->Preise->Sonderpreis_aktiv && isset($Einstellungen.artikeluebersicht) && $Einstellungen.artikeluebersicht.artikeluebersicht_sonderpreisanzeige == 2}
                                <div class="instead-of old-price">
                                    <small class="text-muted-util">
                                        {if $iwListingHasUvp}
                                            <del class="value">{$Artikel->getUVPLocalized($NettoPreise)}</del>
                                        {else}
                                            <del class="value">{$Artikel->Preise->alterVKLocalized[$NettoPreise]}</del>
                                        {/if}
                                    </small>
                                </div>
                            {elseif !$Artikel->Preise->Sonderpreis_aktiv && $Artikel->Preise->rabatt > 0 && isset($Einstellungen.artikeluebersicht)}
                                {if $Einstellungen.artikeluebersicht.artikeluebersicht_rabattanzeige == 3 || $Einstellungen.artikeluebersicht.artikeluebersicht_rabattanzeige == 4}
                                    <div class="old-price">
                                        <small class="text-muted-util">
                                            {if $iwListingHasUvp}
                                                <del class="value text-nowrap-util">{$Artikel->getUVPLocalized($NettoPreise)}</del>
                                            {else}
                                                <del class="value text-nowrap-util">{$Artikel->Preise->alterVKLocalized[$NettoPreise]}</del>
                                            {/if}
                                        </small>
                                    </div>
                                {/if}
                                {if $Einstellungen.artikeluebersicht.artikeluebersicht_rabattanzeige == 2 || isset($Einstellungen.artikeluebersicht) && $Einstellungen.artikeluebersicht.artikeluebersicht_rabattanzeige == 4}
                                    <div class="discount">
                                        <small class="text-muted-util">
                                            {lang key='discount'}:
                                            <span class="value text-nowrap-util">{$Artikel->Preise->rabatt}%</span>
                                        </small>
                                    </div>
                                {/if}
                            {/if}
                        {/block}
                    </div>
                    {/block}
                {/if}
            {/if}
            {/block}
        </div>
    {else}
        {block name='price-invisible'}
            <span class="price_label price_invisible">{lang key='priceHidden'}</span>
        {/block}
    {/if}
{/block}
