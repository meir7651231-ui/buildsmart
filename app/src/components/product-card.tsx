import type { Product } from '../data/products';
import { openProduct, qtyOf, incQty, decQty, setQty } from '../store/app-store';

type Props = { product: Product };

export function ProductCard({ product }: Props) {
  const qty = qtyOf(product.id);
  const inCart = qty > 0;

  return (
    <div class={`product${inCart ? ' product--in-cart' : ''}`}>
      <button
        type="button"
        class="product__hit"
        onClick={() => openProduct(product.id)}
        aria-label={`פתח ${product.name}`}
      >
        <div class="product__image" aria-hidden="true">
          <span>{product.emoji}</span>
          {inCart && <span class="product__check" aria-hidden="true">✓</span>}
        </div>
        <div class="product__body">
          <div class="product__name">{product.name}</div>
          <div class="product__price">
            ₪{product.price.toLocaleString('he-IL', {
              minimumFractionDigits: product.price % 1 ? 2 : 0,
            })}
            <span class="product__unit">/{product.unit}</span>
          </div>
        </div>
      </button>

      <div class="stepper" onClick={(e) => e.stopPropagation()}>
        {inCart ? (
          <>
            <button
              type="button"
              class="stepper__btn stepper__btn--minus"
              aria-label="הפחת"
              onClick={() => decQty(product.id)}
            >
              −
            </button>
            <input
              type="number"
              inputMode="numeric"
              min={0}
              class="stepper__qty"
              value={qty}
              onInput={(e) => {
                const v = parseInt((e.target as HTMLInputElement).value, 10);
                setQty(product.id, Number.isFinite(v) && v >= 0 ? v : 0);
              }}
              aria-label="כמות"
            />
            <button
              type="button"
              class="stepper__btn stepper__btn--plus"
              aria-label="הוסף"
              onClick={() => incQty(product.id)}
            >
              +
            </button>
          </>
        ) : (
          <button
            type="button"
            class="stepper__add"
            aria-label="הוסף לעגלה"
            onClick={() => incQty(product.id)}
          >
            <svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
              <path d="M12 5v14M5 12h14" />
            </svg>
            <span>לעגלה</span>
          </button>
        )}
      </div>
    </div>
  );
}
