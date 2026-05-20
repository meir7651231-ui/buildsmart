import { useState } from 'preact/hooks';
import { openedProductId, closeProduct, addToCart } from '../store/app-store';
import { productById } from '../data/products';

export function ProductSheet() {
  const id = openedProductId.value;
  if (!id) return null;
  const product = productById(id);
  if (!product) return null;
  return <ProductSheetPanel productId={id} />;
}

function ProductSheetPanel({ productId }: { productId: string }) {
  const product = productById(productId)!;
  const [qty, setQty] = useState(1);

  const total = (product.price * qty).toLocaleString('he-IL', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2,
  });

  const onConfirm = () => {
    addToCart(productId, qty);
    closeProduct();
  };

  return (
    <div class="sheet" role="dialog" aria-modal="true" aria-label={product.name}>
      <button type="button" class="sheet__backdrop" aria-label="סגור" onClick={closeProduct} />
      <div class="sheet__panel sheet__panel--product">
        <div class="sheet__handle" aria-hidden="true" />

        <div class="psheet__image" aria-hidden="true">{product.emoji}</div>

        <h2 class="psheet__name">{product.name}</h2>
        <p class="psheet__supplier">ספק: {product.supplier}</p>

        <div class="psheet__price">
          ₪{product.price.toLocaleString('he-IL', { minimumFractionDigits: product.price % 1 ? 2 : 0 })}
          <span class="psheet__unit">/{product.unit}</span>
        </div>

        <div class="qty">
          <button
            type="button"
            class="qty__btn"
            aria-label="הפחת"
            onClick={() => setQty((q) => Math.max(1, q - 1))}
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
              setQty(Number.isFinite(v) && v >= 1 ? v : 1);
            }}
            aria-label="כמות"
          />
          <button
            type="button"
            class="qty__btn"
            aria-label="הוסף"
            onClick={() => setQty((q) => q + 1)}
          >
            +
          </button>
        </div>

        <div class="psheet__total">סה״כ: <strong>₪{total}</strong></div>

        <button type="button" class="psheet__cta" onClick={onConfirm}>
          הוסף לעגלה
        </button>
      </div>
    </div>
  );
}
