import { useState } from 'preact/hooks';
import { openedProductId, closeProduct, setQty, qtyOf } from '../store/app-store';
import { productById } from '../data/catalog';

export function ProductSheet() {
  const id = openedProductId.value;
  if (!id) return null;
  const product = productById(id);
  if (!product) return null;
  return <ProductSheetPanel productId={id} />;
}

function ProductSheetPanel({ productId }: { productId: string }) {
  const product = productById(productId)!;
  const existing = qtyOf(productId);
  const [qty, setLocalQty] = useState(existing > 0 ? existing : 1);

  const onConfirm = () => {
    setQty(productId, qty);
    closeProduct();
  };

  const hasPrice = typeof product.price === 'number' && product.price > 0;
  const total = hasPrice
    ? (product.price! * qty).toLocaleString('he-IL', {
        minimumFractionDigits: 2,
        maximumFractionDigits: 2,
      })
    : null;

  return (
    <div class="sheet" role="dialog" aria-modal="true" aria-label={product.name}>
      <button type="button" class="sheet__backdrop" aria-label="סגור" onClick={closeProduct} />
      <div class="sheet__panel sheet__panel--product">
        <div class="sheet__handle" aria-hidden="true" />

        <div class="psheet__image" aria-hidden="true">
          {product.image ? (
            <img src={product.image} alt="" loading="eager" />
          ) : (
            <span>{product.emoji}</span>
          )}
        </div>

        <h2 class="psheet__name">{product.name}</h2>
        {product.productType && (
          <p class="psheet__supplier">{product.productType}</p>
        )}
        {product.note && <p class="psheet__note">{product.note}</p>}

        {hasPrice ? (
          <div class="psheet__price">
            ₪{product.price!.toLocaleString('he-IL', {
              minimumFractionDigits: product.price! % 1 ? 2 : 0,
            })}
          </div>
        ) : (
          <div class="psheet__price psheet__price--pending">מחיר לפי ספק</div>
        )}

        <div class="qty">
          <button
            type="button"
            class="qty__btn"
            aria-label="הפחת"
            onClick={() => setLocalQty((q) => Math.max(1, q - 1))}
          >
            −
          </button>
          <input
            type="number"
            inputMode="numeric"
            min={1}
            class="qty__input"
            value={qty}
            onInput={(e) => {
              const v = parseInt((e.target as HTMLInputElement).value, 10);
              setLocalQty(Number.isFinite(v) && v >= 1 ? v : 1);
            }}
            aria-label="כמות"
          />
          <button
            type="button"
            class="qty__btn"
            aria-label="הוסף"
            onClick={() => setLocalQty((q) => q + 1)}
          >
            +
          </button>
        </div>

        {total && (
          <div class="psheet__total">סה״כ: <strong>₪{total}</strong></div>
        )}

        <button type="button" class="psheet__cta" onClick={onConfirm}>
          הוסף לעגלה
        </button>
      </div>
    </div>
  );
}
