{block name='productlist-item-slider'}
    {block name='productlist-item-slider-link'}
        {link href=$Artikel->cURLFull}
            <div class="item-slider productbox-image square square-image">
                <div class="inner">
                    {* === IW Rabatt-Badge ===
                       Streichpreis = max(VKBrutto, UVP). 7-stufige Fallback-Kaskade,
                       identisch zu item_box.tpl. alterVKNetto = NETZdinge-Hauptquelle. *}
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
                        {* Fallback 4: alterVKNetto – Netto-Streichpreis (NETZdinge-Hauptquelle) *}
                        {if $iwRabatt < 1}
                            {assign var=iwVkN value=$Artikel->Preise->fVKNetto|default:0}
                            {assign var=iwAltN value=$Artikel->Preise->alterVKNetto|default:0}
                            {if $iwVkN > 0 && $iwAltN > 0 && $iwAltN > $iwVkN}
                                {math equation="round((1 - vkn/altn) * 100)" vkn=$iwVkN altn=$iwAltN assign="iwRabatt"}
                            {/if}
                        {/if}
                        {* Fallback 5: fVKNetto vs. fPreis *}
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
                        {* Fallback 7: JTL berechneSieSparenX() *}
                        {if $iwRabatt < 1}
                            {assign var=Artikel value=$Artikel->berechneSieSparenX()}
                            {if isset($Artikel->SieSparenX->nProzent) && $Artikel->SieSparenX->nProzent > 0}
                                {assign var=iwRabatt value=$Artikel->SieSparenX->nProzent|round:0}
                            {/if}
                        {/if}
                    {/if}

                    {* Limited badge: nur wenn kein Rabatt-Badge aktiv *}
                    {assign var=limitCountInt value=$Artikel->FunktionsAttribute['limitiert_anzahl']|default:''|intval}
                    {if $limitCountInt > 0 && $iwRabatt < 1}
                        <div class="iw-badge-limited-overlay iw-badge-limited--listing" aria-label="{$limitCountInt} Stück limitiert">
                            {$limitCountInt} Stück limitiert
                        </div>
                    {/if}

                    {* Rabatt-Badge oben links, bündig am Bildrand *}
                    {if $iwRabatt >= 1}
                        <div class="iw-badge-discount iw-badge-discount--listing iw-badge-discount--edge" style="top:0;left:0;border-radius:0 0 .45rem 0;padding:5px 9px;min-width:46px;min-height:24px;box-shadow:0 1px 4px rgba(0,0,0,.14);" aria-label="-{$iwRabatt|round:0} Prozent Rabatt">-{$iwRabatt|round:0}&thinsp;%</div>
                    {/if}

                    {if isset($Artikel->Bilder[0]->cAltAttribut)}
                        {assign var=alt value=$Artikel->Bilder[0]->cAltAttribut|truncate:60}
                    {else}
                        {assign var=alt value=$Artikel->cName}
                    {/if}
                    {block name='productlist-item-slider-image'}
                        {if $tplscope === 'half'}
                            {$imgSizes = '(min-width: 1300px) 19vw, (min-width: 992px) 29vw, 50vw'}
                        {elseif $tplscope === 'slider'}
                            {$imgSizes = '(min-width: 1300px) 15vw, (min-width: 992px) 20vw, (min-width: 768px) 34vw, 50vw'}
                        {elseif $tplscope === 'box'}
                            {$imgSizes = '(min-width: 1300px) 25vw, (min-width: 992px) 34vw, (min-width: 768px) 100vw, 50vw'}
                        {/if}
                        {include file='snippets/image.tpl' item=$Artikel
                            square=false
                            srcSize='sm'
                            class='product-image'
                            sizes=$imgSizes|default:'100vw'
                        }
                    {/block}
                    {if $tplscope !== 'box'}
                        <meta itemprop="image" content="{$Artikel->Bilder[0]->cURLNormal}">
                        <meta itemprop="url" content="{$Artikel->cURLFull}">
                    {/if}
                </div>
            </div>
            {block name='productlist-item-slider-caption'}
                {if empty($noCaptionSlider)}
                    {block name='productlist-item-slider-caption-short-desc'}
                        <span class="item-slider-desc">
                            {if !empty($Artikel->cHersteller)}
                                <span class="item-slider-brand">{$Artikel->cHersteller}</span>
                            {/if}
                            <span class="text-clamp-2">{if isset($showPartsList) && $showPartsList === true && isset($Artikel->fAnzahl_stueckliste)}
                                {block name='productlist-item-slider-caption-bundle'}
                                    {$Artikel->fAnzahl_stueckliste}x
                                {/block}
                            {/if}
                            <span {if $tplscope !== 'box'}itemprop="name"{/if}>{$Artikel->cKurzbezeichnung}</span>
                        </span>
                        </span>
                    {/block}
                    {if $tplscope === 'box'}
                        {if $Einstellungen.bewertung.bewertung_anzeigen === 'Y' && $Artikel->fDurchschnittsBewertung > 0}
                            {block name='productlist-item-slider-include-rating'}
                                <small class="item-slider-rating">{include file='productdetails/rating.tpl' stars=$Artikel->fDurchschnittsBewertung link=$Artikel->cURLFull}</small>
                            {/block}
                        {/if}
                    {/if}
                    {block name='productlist-item-slider-include-price'}
                        <div class="item-slider-price" itemprop="offers" itemscope itemtype="https://schema.org/Offer">
                            <div class="iw-price-inline">
                                {include file='productdetails/price.tpl' Artikel=$Artikel tplscope=$tplscope}
                            </div>
                        </div>
                    {/block}
                {/if}
            {/block}
        {/link}
    {/block}
{/block}
