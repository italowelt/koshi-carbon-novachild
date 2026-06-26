{block name='productdetails-attributes'}
{$inQuickView = !empty($smarty.get.quickView)}

{if $showAttributesTable}
    {assign var='vehicleManufacturerCharacteristic' value=false}
    {assign var='vehicleModelCharacteristic' value=false}
    {assign var='vehicleOverviewRendered' value=0}

    {if $Einstellungen.artikeldetails.merkmale_anzeigen === 'Y'}
        {foreach $Artikel->oMerkmale_arr as $characteristic}
            {assign var='characteristicNameNormalized' value=$characteristic->getName()|trim|lower}

            {if $characteristicNameNormalized === 'fahrzeughersteller'
                || $characteristicNameNormalized === 'hersteller'
                || $characteristicNameNormalized === 'marke'}
                {assign var='vehicleManufacturerCharacteristic' value=$characteristic}
            {elseif $characteristicNameNormalized === 'fahrzeugmodell'
                || $characteristicNameNormalized === 'modell'
                || $characteristicNameNormalized === 'fahrzeugtyp'}
                {assign var='vehicleModelCharacteristic' value=$characteristic}
            {/if}
        {/foreach}
    {/if}

    <div class="product-attributes iw-product-attributes">

        {if $vehicleManufacturerCharacteristic || $vehicleModelCharacteristic}
            <section class="iw-fitment-overview">
                

                {if $vehicleManufacturerCharacteristic && $vehicleModelCharacteristic}
                    {assign var='vehicleOverviewRendered' value=1}
                    {assign var='manufacturerCount' value=$vehicleManufacturerCharacteristic->getCharacteristicValues()|count}

                    <div class="iw-fitment-grid">
                        {foreach $vehicleManufacturerCharacteristic->getCharacteristicValues() as $manufacturerValue}
                            {assign var='manufacturerName' value=$manufacturerValue->getValue()|trim}
                            {assign var='manufacturerNameNormalized' value=$manufacturerName|lower}
                            {assign var='manufacturerNeedle' value=$manufacturerNameNormalized}
                            {assign var='manufacturerNeedleAlt' value=''}

                            {if $manufacturerNameNormalized === 'alfa romeo'}
                                {assign var='manufacturerNeedleAlt' value='alfa '}
                            {elseif $manufacturerNameNormalized === 'ds automobiles' || $manufacturerNameNormalized === 'ds'}
                                {assign var='manufacturerNeedle' value='ds '}
                                {assign var='manufacturerNeedleAlt' value='ds automobiles '}
                            {elseif $manufacturerNameNormalized === 'citroën'}
                                {assign var='manufacturerNeedle' value='citroën '}
                                {assign var='manufacturerNeedleAlt' value='citroen '}
                            {elseif $manufacturerNameNormalized === 'citroen'}
                                {assign var='manufacturerNeedle' value='citroen '}
                                {assign var='manufacturerNeedleAlt' value='citroën '}
                            {/if}

                            <div class="iw-fitment-card">
                                <div class="iw-fitment-card__brand">
                                    <a {if !$inQuickView}href="{$manufacturerValue->getURL()}"{/if} class="iw-fitment-card__brand-link">
                                        {assign var='brandImg' value=$manufacturerValue->getImage(\JTL\Media\Image::SIZE_XS)}
                                        {if $brandImg !== null
                                            && strpos($brandImg, $smarty.const.BILD_KEIN_MERKMALBILD_VORHANDEN) === false
                                            && strpos($brandImg, $smarty.const.BILD_KEIN_ARTIKELBILD_VORHANDEN) === false}
                                            <span class="iw-fitment-card__brand-logo">
                                                <img src="{$brandImg|escape:'html'}"
                                                     width="40"
                                                     height="40"
                                                     loading="lazy"
                                                     decoding="async"
                                                     class="img-aspect-ratio"
                                                     alt="{$manufacturerName|default:'Fahrzeughersteller'|escape:'html'}">
                                            </span>
                                        {/if}

                                        
                                    </a>
                                </div>

                                <div class="iw-fitment-card__models">
                                    {foreach $vehicleModelCharacteristic->getCharacteristicValues() as $modelValue}
                                        {assign var='modelName' value=$modelValue->getValue()|trim}
                                        {assign var='modelNameNormalized' value=$modelName|lower}
                                        {assign var='isAssignedToManufacturer' value=0}

                                        {if $manufacturerCount == 1}
                                            {assign var='isAssignedToManufacturer' value=1}
                                        {elseif strpos($modelNameNormalized, $manufacturerNeedle) === 0}
                                            {assign var='isAssignedToManufacturer' value=1}
                                        {elseif $manufacturerNeedleAlt|count_characters > 0 && strpos($modelNameNormalized, $manufacturerNeedleAlt) === 0}
                                            {assign var='isAssignedToManufacturer' value=1}
                                        {/if}

                                        {if $isAssignedToManufacturer}
                                            <a {if !$inQuickView}href="{$modelValue->getURL()}"{/if} class="badge badge-primary iw-fitment-chip">
                                                {$modelName|escape:'html'}
                                            </a>
                                        {/if}
                                    {/foreach}
                                </div>
                            </div>
                        {/foreach}

                        {assign var='hasUnassignedModels' value=0}

                        {if $manufacturerCount > 1}
                            {foreach $vehicleModelCharacteristic->getCharacteristicValues() as $modelValue}
                                {assign var='modelName' value=$modelValue->getValue()|trim}
                                {assign var='modelNameNormalized' value=$modelName|lower}
                                {assign var='modelWasAssigned' value=0}

                                {foreach $vehicleManufacturerCharacteristic->getCharacteristicValues() as $manufacturerValue}
                                    {assign var='manufacturerName' value=$manufacturerValue->getValue()|trim}
                                    {assign var='manufacturerNameNormalized' value=$manufacturerName|lower}
                                    {assign var='manufacturerNeedle' value=$manufacturerNameNormalized}
                                    {assign var='manufacturerNeedleAlt' value=''}

                                    {if $manufacturerNameNormalized === 'alfa romeo'}
                                        {assign var='manufacturerNeedleAlt' value='alfa '}
                                    {elseif $manufacturerNameNormalized === 'ds automobiles' || $manufacturerNameNormalized === 'ds'}
                                        {assign var='manufacturerNeedle' value='ds '}
                                        {assign var='manufacturerNeedleAlt' value='ds automobiles '}
                                    {elseif $manufacturerNameNormalized === 'citroën'}
                                        {assign var='manufacturerNeedle' value='citroën '}
                                        {assign var='manufacturerNeedleAlt' value='citroen '}
                                    {elseif $manufacturerNameNormalized === 'citroen'}
                                        {assign var='manufacturerNeedle' value='citroen '}
                                        {assign var='manufacturerNeedleAlt' value='citroën '}
                                    {/if}

                                    {if strpos($modelNameNormalized, $manufacturerNeedle) === 0}
                                        {assign var='modelWasAssigned' value=1}
                                    {elseif $manufacturerNeedleAlt|count_characters > 0 && strpos($modelNameNormalized, $manufacturerNeedleAlt) === 0}
                                        {assign var='modelWasAssigned' value=1}
                                    {/if}
                                {/foreach}

                                {if !$modelWasAssigned}
                                    {assign var='hasUnassignedModels' value=1}
                                {/if}
                            {/foreach}
                        {/if}

                        {if $hasUnassignedModels}
                            <div class="iw-fitment-card iw-fitment-card--fallback">
                                <div class="iw-fitment-card__brand">
                                    <span class="iw-fitment-card__brand-name">Weitere Modelle</span>
                                </div>

                                <div class="iw-fitment-card__models">
                                    {foreach $vehicleModelCharacteristic->getCharacteristicValues() as $modelValue}
                                        {assign var='modelName' value=$modelValue->getValue()|trim}
                                        {assign var='modelNameNormalized' value=$modelName|lower}
                                        {assign var='modelWasAssigned' value=0}

                                        {foreach $vehicleManufacturerCharacteristic->getCharacteristicValues() as $manufacturerValue}
                                            {assign var='manufacturerName' value=$manufacturerValue->getValue()|trim}
                                            {assign var='manufacturerNameNormalized' value=$manufacturerName|lower}
                                            {assign var='manufacturerNeedle' value=$manufacturerNameNormalized}
                                            {assign var='manufacturerNeedleAlt' value=''}

                                            {if $manufacturerNameNormalized === 'alfa romeo'}
                                                {assign var='manufacturerNeedleAlt' value='alfa '}
                                            {elseif $manufacturerNameNormalized === 'ds automobiles' || $manufacturerNameNormalized === 'ds'}
                                                {assign var='manufacturerNeedle' value='ds '}
                                                {assign var='manufacturerNeedleAlt' value='ds automobiles '}
                                            {elseif $manufacturerNameNormalized === 'citroën'}
                                                {assign var='manufacturerNeedle' value='citroën '}
                                                {assign var='manufacturerNeedleAlt' value='citroen '}
                                            {elseif $manufacturerNameNormalized === 'citroen'}
                                                {assign var='manufacturerNeedle' value='citroen '}
                                                {assign var='manufacturerNeedleAlt' value='citroën '}
                                            {/if}

                                            {if strpos($modelNameNormalized, $manufacturerNeedle) === 0}
                                                {assign var='modelWasAssigned' value=1}
                                            {elseif $manufacturerNeedleAlt|count_characters > 0 && strpos($modelNameNormalized, $manufacturerNeedleAlt) === 0}
                                                {assign var='modelWasAssigned' value=1}
                                            {/if}
                                        {/foreach}

                                        {if !$modelWasAssigned}
                                            <a {if !$inQuickView}href="{$modelValue->getURL()}"{/if} class="badge badge-primary iw-fitment-chip">
                                                {$modelName|escape:'html'}
                                            </a>
                                        {/if}
                                    {/foreach}
                                </div>
                            </div>
                        {/if}
                    </div>

                {elseif $vehicleModelCharacteristic}
                    {assign var='vehicleOverviewRendered' value=1}
                    <div class="iw-fitment-card iw-fitment-card--full">
                        <div class="iw-fitment-card__models">
                            {foreach $vehicleModelCharacteristic->getCharacteristicValues() as $modelValue}
                                <a {if !$inQuickView}href="{$modelValue->getURL()}"{/if} class="badge badge-primary iw-fitment-chip">
                                    {$modelValue->getValue()|escape:'html'}
                                </a>
                            {/foreach}
                        </div>
                    </div>

                {elseif $vehicleManufacturerCharacteristic}
                    {assign var='vehicleOverviewRendered' value=1}
                    <div class="iw-fitment-card iw-fitment-card--full">
                        <div class="iw-fitment-card__models">
                            {foreach $vehicleManufacturerCharacteristic->getCharacteristicValues() as $manufacturerValue}
                                <a {if !$inQuickView}href="{$manufacturerValue->getURL()}"{/if} class="badge badge-primary iw-fitment-chip">
                                    {$manufacturerValue->getValue()|escape:'html'}
                                </a>
                            {/foreach}
                        </div>
                    </div>
                {/if}
            </section>
        {/if}

        {block name='productdetails-attributes-table'}
            <table class="table table-sm table-striped table-bordered-outline iw-product-attributes-table">
                <thead>
                    <tr>
                        <th scope="col" class="sr-only">{lang section="productDetails" key='itemInformation'}</th>
                        <th scope="col" class="sr-only">{lang section="productDetails" key='itemValue'}</th>
                    </tr>
                </thead>
                <tbody>
                    {if $Einstellungen.artikeldetails.merkmale_anzeigen === 'Y'}
                        {block name='productdetails-attributes-characteristics'}
                            {foreach $Artikel->oMerkmale_arr as $characteristic}
                                {assign var='characteristicNameNormalized' value=$characteristic->getName()|trim|lower}
                                {assign var='isVehicleManufacturerRow' value=0}
                                {assign var='isVehicleModelRow' value=0}

                                {if $characteristicNameNormalized === 'fahrzeughersteller'
                                    || $characteristicNameNormalized === 'hersteller'
                                    || $characteristicNameNormalized === 'marke'}
                                    {assign var='isVehicleManufacturerRow' value=1}
                                {/if}

                                {if $characteristicNameNormalized === 'fahrzeugmodell'
                                    || $characteristicNameNormalized === 'modell'
                                    || $characteristicNameNormalized === 'fahrzeugtyp'}
                                    {assign var='isVehicleModelRow' value=1}
                                {/if}

                                {if !($vehicleOverviewRendered && ($isVehicleManufacturerRow || $isVehicleModelRow))}
                                    <tr>
                                        <td class="h6 iw-attr-label">{$characteristic->getName()|escape:'html'}:</td>
                                        <td class="attr-characteristic iw-attr-values">
                                            {strip}
                                                {foreach $characteristic->getCharacteristicValues() as $characteristicValue}
                                                    {if $characteristic->getType() === 'TEXT' || $characteristic->getType() === 'SELECTBOX' || $characteristic->getType() === ''}
                                                        {block name='productdetails-attributes-badge'}
                                                            <a {if !$inQuickView}href="{$characteristicValue->getURL()}"{/if} class="badge badge-primary iw-attr-badge">
                                                                {$characteristicValue->getValue()|escape:'html'}
                                                            </a>
                                                        {/block}
                                                    {else}
                                                        {block name='productdetails-attributes-image'}
                                                            <a {if !$inQuickView}href="{$characteristicValue->getURL()}"{/if}
                                                               class="text-decoration-none-util iw-attr-image-link"
                                                               data-toggle="tooltip" data-placement="top" data-boundary="window"
                                                               title="{$characteristicValue->getValue()|escape:'html'}"
                                                               aria-label="{$characteristicValue->getValue()|escape:'html'}">
                                                                {assign var='img' value=$characteristicValue->getImage(\JTL\Media\Image::SIZE_XS)}
                                                                {if $img !== null
                                                                    && strpos($img, $smarty.const.BILD_KEIN_MERKMALBILD_VORHANDEN) === false
                                                                    && strpos($img, $smarty.const.BILD_KEIN_ARTIKELBILD_VORHANDEN) === false}
                                                                    <span class="iw-attr-image">
                                                                        {include file='snippets/image.tpl'
                                                                            item=$characteristicValue
                                                                            square=false
                                                                            srcSize='xs'
                                                                            sizes='40px'
                                                                            width='40'
                                                                            height='40'
                                                                            class='img-aspect-ratio'
                                                                            alt=$characteristicValue->getValue()}
                                                                    </span>
                                                                {else}
                                                                    {badge variant="primary"}{$characteristicValue->getValue()|escape:'html'}{/badge}
                                                                {/if}
                                                            </a>
                                                        {/block}
                                                    {/if}
                                                {/foreach}
                                            {/strip}
                                        </td>
                                    </tr>
                                {/if}
                            {/foreach}
                        {/block}
                    {/if}

                    {if $showShippingWeight}
                        {block name='productdetails-attributes-shipping-weight'}
                            <tr>
                                <td class="h6 iw-attr-label">{lang key='shippingWeight'}:</td>
                                <td class="weight-unit iw-attr-values">
                                    {$Artikel->cGewicht} {lang key='weightUnit'}
                                </td>
                            </tr>
                        {/block}
                    {/if}

                    {if $showProductWeight}
                        {block name='productdetails-attributes-product-weight'}
                            <tr class="attr-weight">
                                <td class="h6 iw-attr-label">{lang key='productWeight'}:</td>
                                <td class="weight-unit iw-attr-values" itemprop="weight" itemscope itemtype="https://schema.org/QuantitativeValue">
                                    <span itemprop="value">{$Artikel->cArtikelgewicht}</span> <span itemprop="unitText">{lang key='weightUnit'}</span>
                                </td>
                            </tr>
                        {/block}
                    {/if}

                    {if $Einstellungen.artikeldetails.artikeldetails_inhalt_anzeigen === 'Y'
                        && isset($Artikel->cMasseinheitName)
                        && isset($Artikel->fMassMenge)
                        && $Artikel->fMassMenge > 0
                        && $Artikel->cTeilbar !== 'Y'
                        && ($Artikel->fAbnahmeintervall == 0 || $Artikel->fAbnahmeintervall == 1)
                        && isset($Artikel->cMassMenge)}
                        {block name='productdetails-attributes-unit'}
                            <tr class="attr-contents">
                                <td class="h6 iw-attr-label">{lang key='contents' section='productDetails'}:</td>
                                <td class="attr-value iw-attr-values">
                                    {$Artikel->cMassMenge} {$Artikel->cMasseinheitName}
                                </td>
                            </tr>
                        {/block}
                    {/if}

                    {if $dimension && $Einstellungen.artikeldetails.artikeldetails_abmessungen_anzeigen === 'Y'}
                        {block name='productdetails-attributes-dimensions'}
                            {assign var='dimensionArr' value=$Artikel->getDimensionLocalized()}
                            {if $dimensionArr|count > 0}
                                <tr class="attr-dimensions">
                                    <td class="h6 iw-attr-label">
                                        {lang key='dimensions' section='productDetails'}
                                        ({foreach $dimensionArr as $dimkey => $dim}
                                            {$dimkey}{if !$dim@last} &times; {/if}
                                        {/foreach}):
                                    </td>
                                    <td class="attr-value iw-attr-values">
                                        {foreach $dimensionArr as $dim}
                                            {$dim}{if $dim@last} cm {else} &times; {/if}
                                        {/foreach}
                                    </td>
                                </tr>
                            {/if}
                        {/block}
                    {/if}

                    {if $Einstellungen.artikeldetails.artikeldetails_attribute_anhaengen === 'Y'
                        || $Artikel->FunktionsAttribute[$smarty.const.FKT_ATTRIBUT_ATTRIBUTEANHAENGEN]|default:0 == 1}
                        {block name='productdetails-attributes-shop-attributes'}
                            {foreach $Artikel->Attribute as $Attribut}
                                <tr class="attr-custom">
                                    <td class="h6 iw-attr-label">{$Attribut->cName}:</td>
                                    <td class="attr-value iw-attr-values">{$Attribut->cWert}</td>
                                </tr>
                            {/foreach}
                        {/block}
                    {/if}
                </tbody>
            </table>
        {/block}
    </div>
{/if}
{/block}