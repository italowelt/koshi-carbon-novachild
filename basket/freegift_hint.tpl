{block name='basket-freegift-hint'}
    {if $Einstellungen.sonstiges.sonstiges_gratisgeschenk_wk_hinweis_anzeigen === 'Y'
    && isset($freeGifts)
    && $freeGifts->count() > 0}
        {$freeGiftService = JTL\Shop::Container()->getFreeGiftService()}
        {if $freeGiftService->basketHoldsFreeGift(JTL\Session\Frontend::getCart()) === false}
            <div class="iw-freegift-hint">
                <div class="iw-freegift-hint__title font-weight-bold">
                    {if !empty($oSpezialseiten_arr) && isset($oSpezialseiten_arr[$smarty.const.LINKTYP_GRATISGESCHENK])}
                        <a href="{$oSpezialseiten_arr[$smarty.const.LINKTYP_GRATISGESCHENK]->getURL()}"
                           title="{lang key='freeGiftsSeeAll' section='basket'}"><i class="fas fa-gifts text-dark mr-1"></i></a>
                    {else}
                        <i class="fas fa-gifts text-dark mr-1"></i>
                    {/if}
                    <span>{lang key='freeGiftsAvailable' section='basket'}</span>
                </div>
                <span class="iw-freegift-hint__text d-block">{lang section='basket' key='freeGiftsAvailableText'}</span>
            </div>
        {/if}
    {/if}
{/block}
