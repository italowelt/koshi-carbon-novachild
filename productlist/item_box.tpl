{block name='productlist-item-box'}
    {if $Einstellungen.template.productlist.variation_select_productlist_gallery === 'N'}
        {assign var=hasOnlyListableVariations value=0}
        {$showVariationCollapse = false}
    {else}
        {hasOnlyListableVariations artikel=$Artikel
            maxVariationCount=$Einstellungen.template.productlist.variation_select_productlist_gallery
            maxWerteCount=$Einstellungen.template.productlist.variation_max_werte_productlist_gallery
            assign='hasOnlyListableVariations'}
        {$showVariationCollapse = ($hasOnlyListableVariations > 0 && $Artikel->nIstVater && !$Artikel->bHasKonfig && $Artikel->kEigenschaftKombi === 0 &&
        empty($Artikel->FunktionsAttribute[\FKT_ATTRIBUT_NO_GAL_VAR_PREVIEW]) &&
    $Artikel->nVariationOhneFreifeldAnzahl <= 2 &&
    ($Artikel->Variationen[0]->cTyp === 'IMGSWATCHES' || $Artikel->Variationen[0]->cTyp === 'TEXTSWATCHES' || $Artikel->Variationen[0]->cTyp === 'SELECTBOX') &&
    (!isset($Artikel->Variationen[1]) || ($Artikel->Variationen[1]->cTyp === 'IMGSWATCHES' || $Artikel->Variationen[1]->cTyp === 'TEXTSWATCHES' || $Artikel->Variationen[1]->cTyp === 'SELECTBOX')))}
    {/if}
    <div id="{$idPrefix|default:''}result-wrapper_buy_form_{$Artikel->kArtikel}" data-wrapper="true" role="button"
         tabindex="0"
         class="productbox productbox-column {if !empty($hasOnlyListableVariations) && empty($Artikel->FunktionsAttribute[\FKT_ATTRIBUT_NO_GAL_VAR_PREVIEW])}productbox-show-variations {/if} productbox-hover{if isset($class)} {$class}{/if} {if $showVariationCollapse}show-variation-collapse{/if}">
        {block name='productlist-item-box-include-productlist-actions'}
            <div class="productbox-quick-actions productbox-onhover d-none d-md-flex">
                {include file='productlist/productlist_actions.tpl'}
            </div>
        {/block}

        {form id="{$idPrefix|default:''}buy_form_{$Artikel->kArtikel}"
        action=$ShopURL class="form form-basket jtl-validate"
        data=["toggle" => "basket-add"]}
        {input type="hidden" name="a" value="{if !empty({$Artikel->kVariKindArtikel})}{$Artikel->kVariKindArtikel}{else}{$Artikel->kArtikel}{/if}"}
        <div class="productbox-inner">
            {row}
                {col cols=12}
                    <div class="productbox-image" data-target="#variations-collapse-{$Artikel->kArtikel}" aria-expanded="false" aria-controls="variations-collapse-{$Artikel->kArtikel}" role="button">
                        {if isset($Artikel->Bilder[0]->cAltAttribut)}
                            {assign var=alt value=$Artikel->Bilder[0]->cAltAttribut}
                        {else}
                            {assign var=alt value=$Artikel->cName}
                        {/if}
                        {block name='productlist-item-box-image'}
                            {counter assign=imgcounter print=0}

                            {* === IW Rabatt-Badge ===
                               Streichpreis = max(VKBrutto, UVP).
                               Fallback-Kaskade (Reihenfolge wichtig):
                                 1. Sonderpreis (fSonderPreisBrutto) gegen max(VK, UVP)
                                 2. alterPreis gegen max(alterPreis, UVP)
                                 3. nur UVP > VK
                                 4. alterVKNetto (NETTO-Streichpreis – wie NETZdinge-Plugin)
                                 5. fVKNetto vs. fPreis
                                 6. Preise->rabatt
                                 7. JTL berechneSieSparenX()
                               Blocking: 1=Bestseller 4=InKürzeVerfügbar 8=Vorbestellbar *}
                            {assign var=iwVk value=$Artikel->Preise->fVKBrutto|default:0}
                            {assign var=iwUvp value=$Artikel->Preise->fUVPBrutto|default:0}
                            {assign var=iwAlt value=$Artikel->Preise->alterPreis|default:0}
                            {assign var=iwSonder value=$Artikel->Preise->fSonderPreisBrutto|default:0}
                            {assign var=iwUvpArt value=$Artikel->fUVP|default:0}
                            {assign var=iwRabatt value=0}
                            {assign var=iwBlockedSpecial value=false}
                            {if isset($Artikel->oSuchspecialBild->kSuchspecial)}
                                {assign var=iwSpecialId value=$Artikel->oSuchspecialBild->kSuchspecial}
                                {if $iwSpecialId == 1 || $iwSpecialId == 4 || $iwSpecialId == 8}
                                    {assign var=iwBlockedSpecial value=true}
                                {/if}
                            {/if}
                            {if !$iwBlockedSpecial && $iwVk > 0}
                                {assign var=iwUvpRef value=$iwUvp}
                                {if $iwUvpRef < 0.01 && $iwUvpArt > 0}
                                    {assign var=iwUvpRef value=$iwUvpArt}
                                {/if}
                                {if $iwSonder > 0 && $iwVk > $iwSonder}
                                    {if $iwUvpRef > $iwVk}
                                        {math equation="round((1 - sp/ref) * 100)" sp=$iwSonder ref=$iwUvpRef assign="iwRabatt"}
                                    {else}
                                        {math equation="round((1 - sp/ref) * 100)" sp=$iwSonder ref=$iwVk assign="iwRabatt"}
                                    {/if}
                                {elseif $iwAlt > 0 && $iwAlt > $iwVk}
                                    {assign var=iwRef value=$iwAlt}
                                    {if $iwUvpRef > $iwRef}{assign var=iwRef value=$iwUvpRef}{/if}
                                    {math equation="round((1 - vk/ref) * 100)" vk=$iwVk ref=$iwRef assign="iwRabatt"}
                                {elseif $iwUvpRef > 0 && $iwUvpRef > $iwVk}
                                    {math equation="round((1 - vk/ref) * 100)" vk=$iwVk ref=$iwUvpRef assign="iwRabatt"}
                                {/if}
                                {* Fallback 4: alterVKNetto – Netto-Streichpreis (Hauptquelle laut NETZdinge-Plugin).
                                   Formel komplett netto: (1 - fVKNetto / alterVKNetto) * 100 *}
                                {if $iwRabatt < 1}
                                    {assign var=iwVkN value=$Artikel->Preise->fVKNetto|default:0}
                                    {assign var=iwAltN value=$Artikel->Preise->alterVKNetto|default:0}
                                    {if $iwVkN > 0 && $iwAltN > 0 && $iwAltN > $iwVkN}
                                        {math equation="round((1 - vkn/altn) * 100)" vkn=$iwVkN altn=$iwAltN assign="iwRabatt"}
                                    {/if}
                                {/if}
                                {* Fallback 5: fVKNetto vs. fPreis (effektiver Preis netto) *}
                                {if $iwRabatt < 1}
                                    {assign var=iwFbVkN value=$Artikel->Preise->fVKNetto|default:0}
                                    {assign var=iwFbPreis value=$Artikel->Preise->fPreis|default:0}
                                    {if $iwFbVkN > 0 && $iwFbPreis > 0 && $iwFbVkN > $iwFbPreis}
                                        {math equation="round((1 - p/ref) * 100)" p=$iwFbPreis ref=$iwFbVkN assign="iwRabatt"}
                                    {/if}
                                {/if}
                                {* Fallback 6: Preise->rabatt *}
                                {if $iwRabatt < 1 && isset($Artikel->Preise->rabatt) && $Artikel->Preise->rabatt > 0}
                                    {assign var=iwRabatt value=$Artikel->Preise->rabatt|round:0}
                                {/if}
                                {* Fallback 7: JTL berechneSieSparenX() – muss explizit aufgerufen werden *}
                                {if $iwRabatt < 1}
                                    {assign var=Artikel value=$Artikel->berechneSieSparenX()}
                                    {if isset($Artikel->SieSparenX->nProzent) && $Artikel->SieSparenX->nProzent > 0}
                                        {assign var=iwRabatt value=$Artikel->SieSparenX->nProzent|round:0}
                                    {/if}
                                {/if}
                            {/if}

                            {block name='productlist-item-box-include-ribbon'}
                                {if $iwRabatt < 1}{include file='snippets/ribbon.tpl'}{/if}
                            {/block}
                            <div class="productbox-images list-gallery">
                                {assign var=limitCountInt value=$Artikel->FunktionsAttribute['limitiert_anzahl']|default:''|intval}
                                {if $limitCountInt > 0 && $iwRabatt < 1}
                                    <div class="iw-badge-limited-overlay iw-badge-limited--listing" aria-label="{$limitCountInt} Stück limitiert">
                                        {$limitCountInt} Stück limitiert
                                    </div>
                                {/if}
                                {if $iwRabatt >= 1}
                                    <div class="iw-badge-discount iw-badge-discount--listing iw-badge-discount--edge" style="top:0;left:0;border-radius:0 0 .45rem 0;padding:5px 9px;min-width:46px;min-height:24px;box-shadow:0 1px 4px rgba(0,0,0,.14);" aria-label="-{$iwRabatt|round:0} Prozent Rabatt">-{$iwRabatt|round:0}&thinsp;%</div>
                                {/if}
                                {link href=$Artikel->cURLFull tabindex=-1}
                                    {block name="productlist-item-list-image"}
                                        {strip}
                                            {$image = $Artikel->Bilder[0]}
                                            <div class="productbox-image square square-image first-wrapper">
                                                <div class="inner">
                                                    {image alt=$alt|truncate:60 fluid=true webp=true lazy=true
                                                        src="{$image->cURLKlein}"
                                                        srcset="{$image->cURLMini} {$image->imageSizes->xs->size->width}w, {$image->cURLKlein} {$image->imageSizes->sm->size->width}w, {$image->cURLNormal} {$image->imageSizes->md->size->width}w"
                                                        sizes='(min-width: 1300px) 25vw, (min-width: 992px) 34vw, 50vw'
                                                        width=$image->imageSizes->sm->size->width
                                                        height=$image->imageSizes->sm->size->height
                                                        data=["id"  => $imgcounter]
                                                        class="{if !$isMobile && !empty($Artikel->Bilder[1])} first{/if}"
                                                    }
                                                </div>
                                            </div>
                                            {if !$isMobile && !empty($Artikel->Bilder[1])}
                                                <div class="productbox-image square square-image second-wrapper">
                                                    <div class="inner">
                                                    {$image = $Artikel->Bilder[1]}
                                                    {if isset($image->cAltAttribut)}
                                                        {$alt=$image->cAltAttribut}
                                                    {else}
                                                        {$alt=$Artikel->cName}
                                                    {/if}
                                                    {image alt=$alt|truncate:60 fluid=true webp=true lazy=true
                                                        src="{$image->cURLKlein}"
                                                        srcset="{$image->cURLMini} {$image->imageSizes->xs->size->width}w, {$image->cURLKlein} {$image->imageSizes->sm->size->width}w, {$image->cURLNormal} {$image->imageSizes->md->size->width}w"
                                                        sizes='(min-width: 1300px) 25vw, (min-width: 992px) 34vw, 50vw'
                                                        width=$image->imageSizes->sm->size->width
                                                        height=$image->imageSizes->sm->size->height
                                                        data=["id"  => $imgcounter|cat:"_2nd"]
                                                        class='second'
                                                    }
                                                    </div>
                                                </div>
                                            {/if}
                                        {/strip}
                                    {/block}
                                {/link}
                                {if !empty($Artikel->Bilder[0]->cURLNormal)}
                                    <meta itemprop="image" content="{$Artikel->Bilder[0]->cURLNormal}">
                                {/if}
                            </div>
                        {/block}
                    </div>
                {/col}
            {if $showVariationCollapse}
                    {col cols=12 class='productbox-variations'}
                    {block name='productlist-item-box-form-variations'}
                        <div class="productbox-onhover collapse" id="variations-collapse-{$Artikel->kArtikel}">
                            {block name='productlist-item-box-form-include-variation'}
                                {include file='productlist/variation_gallery.tpl'
                                simple=$Artikel->isSimpleVariation showMatrix=false
                                smallView=true ohneFreifeld=($hasOnlyListableVariations == 2)}
                            {/block}
                        </div>
                    {/block}
                    {/col}
                {/if}
                {col cols=12}
                    {block name='productlist-item-box-caption'}
                        {block name='productlist-item-box-caption-short-desc'}
                            <div class="productbox-title" itemprop="name">
                                {if !empty($Artikel->cHersteller)}
                                    <span class="productbox-brand">{$Artikel->cHersteller}</span>
                                {/if}
                                {link href=$Artikel->cURLFull class="text-clamp-2" tabindex=-1}
                                    {$Artikel->cKurzbezeichnung}
                                {/link}
                            </div>
                        {/block}
                        {block name='productlist-item-box-meta'}
                            {if $Artikel->cName !== $Artikel->cKurzbezeichnung}
                                <meta itemprop="alternateName" content="{$Artikel->cName}">
                            {/if}
                            <meta itemprop="url" content="{$Artikel->cURLFull}">
                        {/block}
                        {block name='productlist-index-include-rating'}
                            {if $Einstellungen.bewertung.bewertung_anzeigen === 'Y' && $Artikel->fDurchschnittsBewertung > 0}
                                {include file='productdetails/rating.tpl' stars=$Artikel->fDurchschnittsBewertung
                                    link=$Artikel->cURLFull tplscope='list'}
                            {/if}
                        {/block}
                        {block name='productlist-index-include-price'}
                            <div itemprop="offers" itemscope itemtype="https://schema.org/Offer">
                                <link itemprop="businessFunction" href="http://purl.org/goodrelations/v1#Sell" />
                                <div class="iw-price-inline">
                                    {include file='productdetails/price.tpl' Artikel=$Artikel tplscope=$tplscope}
                                </div>
                            </div>
                        {/block}
                    {/block}
                {/col}
            {/row}
        </div>
        {/form}
    </div>
{/block}
