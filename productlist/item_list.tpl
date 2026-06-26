{block name='productlist-item-list'}
    {block name='productlist-item-list-variables'}
        {if $Einstellungen.template.productlist.variation_select_productlist_list === 'N'}
            {assign var=hasOnlyListableVariations value=0}
        {else}
            {hasOnlyListableVariations artikel=$Artikel
                maxVariationCount=$Einstellungen.template.productlist.variation_select_productlist_list
                maxWerteCount=$Einstellungen.template.productlist.variation_max_werte_productlist_list
                assign='hasOnlyListableVariations'}
        {/if}
        {$isOPC=$isOPC|default:false}
    {/block}
    {block name='productlist-item-list-productbox-outer'}
    <div id="{$idPrefix|default:''}result-wrapper_buy_form_{$Artikel->kArtikel}" data-wrapper="true"
         class="productbox productbox-row productbox-show-variations productbox-hover{if isset($listStyle) && $listStyle === 'list'} active{/if}">
        <div class="productbox-inner">
            {block name='productlist-item-list-productbox-inner'}
            {row}
                {col cols=12 md=4 lg=6 xl=3}
                    {block name='productlist-item-list-image'}
                        <div class="productbox-image">
                            {if isset($Artikel->Bilder[0]->cAltAttribut)}
                                {assign var=alt value=$Artikel->Bilder[0]->cAltAttribut}
                            {else}
                                {assign var=alt value=$Artikel->cName}
                            {/if}
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

                            {block name='productlist-item-list-include-searchspecials'}
                                {if $iwRabatt < 1}{include file='snippets/ribbon.tpl'}{/if}
                            {/block}
                            {block name='productlist-item-box-include-productlist-actions'}
                                <div class="productbox-quick-actions productbox-onhover d-none d-md-flex" role="group" aria-label="{lang key='productActions'}">
                                    {include file='productlist/productlist_actions.tpl'}
                                </div>
                            {/block}
                            {block name="productlist-item-list-images"}
                                <div class="productbox-images">
                                    {assign var=limitCountInt value=$Artikel->FunktionsAttribute['limitiert_anzahl']|default:''|intval}
                                    {if $limitCountInt > 0 && $iwRabatt < 1}
                                        <div class="iw-badge-limited-overlay iw-badge-limited--listing" aria-label="{$limitCountInt} Stück limitiert">
                                            {$limitCountInt} Stück limitiert
                                        </div>
                                    {/if}
                                    {if $iwRabatt >= 1}
                                        <div class="iw-badge-discount iw-badge-discount--listing iw-badge-discount--edge" style="top:0;left:0;border-radius:0 0 .45rem 0;padding:5px 9px;min-width:46px;min-height:24px;box-shadow:0 1px 4px rgba(0,0,0,.14);" aria-label="-{$iwRabatt|round:0} Prozent Rabatt">-{$iwRabatt|round:0}&thinsp;%</div>
                                    {/if}
                                    {link href=$Artikel->cURLFull}
                                        <div class="list-gallery">
                                            {block name="productlist-item-list-images-inner"}
                                                {strip}
                                                    {$image = $Artikel->Bilder[0]}
                                                    <div class="productbox-image square square-image first-wrapper">
                                                        <div class="inner">
                                                            {image alt=$alt|truncate:60 fluid=true webp=true lazy=true
                                                                src="{$image->cURLKlein}"
                                                                srcset="{$image->cURLMini} {$image->imageSizes->xs->size->width}w, {$image->cURLKlein} {$image->imageSizes->sm->size->width}w, {$image->cURLNormal} {$image->imageSizes->md->size->width}w"
                                                                sizes="(min-width: 1300px) 18vw, (min-width: 768px) 30vw, 45vw"
                                                                width=$image->imageSizes->sm->size->width
                                                                height=$image->imageSizes->sm->size->height
                                                                class="{if !$isMobile && !empty($Artikel->Bilder[1])}first{/if}"
                                                            }
                                                        </div>
                                                    </div>
                                                    {if !$isMobile && !empty($Artikel->Bilder[1])}
                                                        {$image = $Artikel->Bilder[1]}
                                                        {if isset($image->cAltAttribut)}
                                                            {assign var=alt value=$image->cAltAttribut}
                                                        {else}
                                                            {assign var=alt value=$Artikel->cName}
                                                        {/if}
                                                        <div class="productbox-image square square-image second-wrapper">
                                                            <div class="inner">
                                                                {image alt=$alt|truncate:60 fluid=true webp=true lazy=true
                                                                    src="{$image->cURLKlein}"
                                                                    srcset="{$image->cURLMini} {$image->imageSizes->xs->size->width}w, {$image->cURLKlein} {$image->imageSizes->sm->size->width}w, {$image->cURLNormal} {$image->imageSizes->md->size->width}w"
                                                                    sizes="(min-width: 1300px) 18vw, (min-width: 768px) 30vw, 45vw"
                                                                    width=$image->imageSizes->sm->size->width
                                                                    height=$image->imageSizes->sm->size->height
                                                                    class="second"
                                                                }
                                                            </div>
                                                        </div>
                                                    {/if}
                                                {/strip}
                                            {/block}
                                        </div>
                                    {/link}
                                    {if !empty($Artikel->Bilder[0]->cURLNormal)}
                                        <meta itemprop="image" content="{$Artikel->Bilder[0]->cURLNormal}">
                                    {/if}
                                </div>
                            {/block}
                        </div>
                    {/block}
                {/col}
                {col md=''}
                    {block name='productlist-item-list-title'}
                        {block name='productlist-item-list-title-heading'}
                            <div class="productbox-title" itemprop="name">
                                {if !empty($Artikel->cHersteller)}
                                    <span class="productbox-brand">{$Artikel->cHersteller}</span>
                                {/if}
                                {link href=$Artikel->cURLFull}{$Artikel->cName}{/link}
                            </div>
                        {/block}
                        <meta itemprop="url" content="{$Artikel->cURLFull}">
                        {if $Einstellungen.artikeluebersicht.artikeluebersicht_kurzbeschreibung_anzeigen === 'Y'
                                && $Artikel->cKurzBeschreibung}
                            {block name='productlist-item-list-description'}
                                <div class="item-list-description" itemprop="description">
                                    {$Artikel->cKurzBeschreibung}
                                </div>
                            {/block}
                        {/if}
                    {/block}
                    {block name='productlist-item-list-buy-form'}
                        {form id="{$idPrefix|default:''}buy_form_{$Artikel->kArtikel}"
                            action=$ShopURL class="form form-basket jtl-validate"
                            data=["toggle" => "basket-add"]}
                            {row}
                                {col cols=12 xl=4 class='productbox-details'}
                                    {block name='productlist-item-list-details'}
                                        {include file='productlist/item_details.tpl'}
                                    {/block}
                                {/col}
                                {col cols=12 xl=4 class='productbox-variations'}
                                    {if $hasOnlyListableVariations > 0 && !$Artikel->bHasKonfig && $Artikel->kEigenschaftKombi === 0}
                                        {block name='productlist-item-list-form-variations'}
                                            <div class="productbox-onhover">
                                                {block name='productlist-item-list-form-include-variation'}
                                                    {include file='productdetails/variation.tpl'
                                                        simple=$Artikel->isSimpleVariation showMatrix=false
                                                        smallView=true ohneFreifeld=($hasOnlyListableVariations == 2)}
                                                {/block}
                                            </div>
                                        {/block}
                                    {/if}
                                {/col}
                                {col cols=12 xl=4 class='productbox-options' itemprop='offers' itemscope=true itemtype='https://schema.org/Offer'}
                                    <link itemprop="businessFunction" href="http://purl.org/goodrelations/v1#Sell" />
                                    {block name='productlist-item-list-form'}
                                        {block name='productlist-item-list-include-price'}
                                            <div class="item-list-price iw-price-inline">
                                                {include file='productdetails/price.tpl' Artikel=$Artikel tplscope=$tplscope}
                                            </div>
                                        {/block}
                                        {block name='productlist-item-list-include-delivery-status'}
                                            {include file='productlist/item_delivery_status.tpl'}
                                        {/block}
                                    {/block}
                                    {block name='productlist-item-list-basket-details'}
                                        {if !$isOPC}
                                        <div class="form-row productbox-onhover productbox-actions item-list-basket-details">
                                            {if ($Artikel->inWarenkorbLegbar === 1
                                                    || ($Artikel->nErscheinendesProdukt === 1 && $Einstellungen.global.global_erscheinende_kaeuflich === 'Y'))
                                                && (($Artikel->nIstVater === 0 && $Artikel->Variationen|count === 0)
                                                    || $hasOnlyListableVariations === 1)
                                                && !$Artikel->bHasKonfig
                                                && $Einstellungen.template.productlist.buy_productlist === 'Y'}
                                                {if $Artikel->nIstVater && $Artikel->kVaterArtikel == 0}
                                                    {col cols=12}
                                                        {block name='productlist-item-list-basket-details-variations'}
                                                            {alert variation="info" class="choose-variations text-left-util"}
                                                                {lang key='chooseVariations' section='messages'}
                                                            {/alert}
                                                        {/block}
                                                    {/col}
                                                {else}
                                                    {col cols=12}
                                                        {block name='productlist-item-list-basket-details-quantity'}
                                                            {inputgroup class="form-counter" data=["bulk" => {!empty($Artikel->staffelPreis_arr)}]}
                                                                {inputgroupprepend}
                                                                    {button variant=""
                                                                        data=["count-down"=>""]
                                                                        aria=["label"=>{lang key='decreaseQuantity' section='aria'}]}
                                                                        <span class="fas fa-minus"></span>
                                                                    {/button}
                                                                {/inputgroupprepend}
                                                                {input type="number" min="0"
                                                                    step="{if $Artikel->cTeilbar === 'Y' && $Artikel->fAbnahmeintervall == 0}any{elseif $Artikel->fAbnahmeintervall > 0}{$Artikel->fAbnahmeintervall}{else}1{/if}"
                                                                    min="{if $Artikel->fMindestbestellmenge}{$Artikel->fMindestbestellmenge}{else}0{/if}"
                                                                    max=$Artikel->FunktionsAttribute[$smarty.const.FKT_ATTRIBUT_MAXBESTELLMENGE]|default:''
                                                                    id="{$idPrefix|default:''}quantity{$Artikel->kArtikel}"
                                                                    class="quantity"
                                                                    name="anzahl"
                                                                    autocomplete="off"
                                                                    aria=["label"=>{lang key='quantity'}]
                                                                    data=[
                                                                        "decimals"=>{getDecimalLength quantity=$Artikel->fAbnahmeintervall},
                                                                        "product-id"=>"{if isset($Artikel->kVariKindArtikel)}{$Artikel->kVariKindArtikel}{else}{$Artikel->kArtikel}{/if}"
                                                                    ]
                                                                    value="{if $Artikel->fAbnahmeintervall > 0 || $Artikel->fMindestbestellmenge > 1}{if $Artikel->fMindestbestellmenge > $Artikel->fAbnahmeintervall}{$Artikel->fMindestbestellmenge}{else}{$Artikel->fAbnahmeintervall}{/if}{else}1{/if}"}
                                                                {inputgroupappend}
                                                                    {button variant=""
                                                                        data=["count-up"=>""]
                                                                        aria=["label"=>{lang key='increaseQuantity' section='aria'}]}
                                                                        <span class="fas fa-plus"></span>
                                                                    {/button}
                                                                {/inputgroupappend}
                                                            {/inputgroup}
                                                        {/block}
                                                    {/col}
                                                    {col cols=12}
                                                        {block name='productlist-item-list-basket-details-add-to-cart'}
                                                            {button type="submit"
                                                                variant="primary"
                                                                block=true id="{$idPrefix|default:''}submit{$Artikel->kArtikel}"
                                                                title="{lang key='addToCart'}"
                                                                class="basket-details-add-to-cart"
                                                                aria=["label"=>{lang key='addToCart'}]}
                                                                {lang key='addToCart'}
                                                            {/button}
                                                        {/block}
                                                    {/col}
                                                {/if}
                                            {else}
                                                {col cols=12}
                                                    {block name='productlist-item-list-basket-details-details'}
                                                        {link class="btn btn-outline-primary btn-block" role="button" href=$Artikel->cURLFull}
                                                            {lang key='details'}
                                                        {/link}
                                                    {/block}
                                                {/col}
                                            {/if}
                                        </div>
                                        {/if}
                                {/block}
                                {block name='productlist-item-form-expandable-inputs-hidden'}
                                    {if $Artikel->kArtikelVariKombi > 0}
                                        {input type="hidden" name="aK" value=$Artikel->kArtikelVariKombi}
                                    {/if}
                                    {if isset($Artikel->kVariKindArtikel)}
                                        {input type="hidden" name="VariKindArtikel" value=$Artikel->kVariKindArtikel}
                                    {/if}
                                    {input type="hidden" name="a" value=$Artikel->kArtikel}
                                    {input type="hidden" name="wke" value="1"}
                                    {input type="hidden" name="overview" value="1"}
                                    {input type="hidden" name="Sortierung" value="{if !empty($Suchergebnisse->Sortierung)}{$Suchergebnisse->Sortierung}{/if}"}
                                    {if $Suchergebnisse->getPages()->getCurrentPage() > 1}
                                        {input type="hidden" name="seite" value=$Suchergebnisse->getPages()->getCurrentPage()}
                                    {/if}
                                    {if $NaviFilter->hasCategory()}
                                        {input type="hidden" name="k" value=$NaviFilter->getCategory()->getValue()}
                                    {/if}
                                    {if $NaviFilter->hasManufacturer()}
                                        {input type="hidden" name="h" value=$NaviFilter->getManufacturer()->getValue()}
                                    {/if}
                                    {if $NaviFilter->hasSearchQuery()}
                                        {input type="hidden" name="l" value=$NaviFilter->getSearchQuery()->getValue()}
                                    {/if}
                                    {if $NaviFilter->hasCharacteristicValue()}
                                        {input type="hidden" name="m" value=$NaviFilter->getCharacteristicValue()->getValue()}
                                    {/if}
                                    {if $NaviFilter->hasCategoryFilter()}
                                        {assign var=cfv value=$NaviFilter->getCategoryFilter()->getValue()}
                                        {if is_array($cfv)}
                                            {foreach $cfv as $val}
                                                {input type="hidden" name="hf" value=$val}
                                            {/foreach}
                                        {else}
                                            {input type="hidden" name="kf" value=$cfv}
                                        {/if}
                                    {/if}
                                    {if $NaviFilter->hasManufacturerFilter()}
                                        {assign var=mfv value=$NaviFilter->getManufacturerFilter()->getValue()}
                                        {if is_array($mfv)}
                                            {foreach $mfv as $val}
                                                {input type="hidden" name="hf" value=$val}
                                            {/foreach}
                                        {else}
                                            {input type="hidden" name="hf" value=$mfv}
                                        {/if}
                                    {/if}
                                    {foreach $NaviFilter->getCharacteristicFilter() as $filter}
                                        {input type="hidden" name="mf{$filter@iteration}" value=$filter->getValue()}
                                    {/foreach}
                                {/block}
                            {/col}
                        {/row}
                    {/form}
                    {/block}
                {/col}
            {/row}
            {/block}
        </div>
    </div>
    {/block}
{/block}
