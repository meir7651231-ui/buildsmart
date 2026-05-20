import type { Product } from '../data/products';
import { openProduct } from '../store/app-store';

type Props = { product: Product };

export function ProductCard({ product }: Props) {
  return (
    <button
      type="button"
      class="product"
      onClick={() => openProduct(product.id)}
      aria-label={`פתח ${product.name}`}
    >
      <div class="product__image" aria-hidden="true">
        <span>{product.emoji}</span>
      </div>
      <div class="product__body">
        <div class="product__name">{product.name}</div>
        <div class="product__supplier">{product.supplier}</div>
        <div class="product__price">
          ₪{product.price.toLocaleString('he-IL', { minimumFractionDigits: product.price % 1 ? 2 : 0 })}
          <span class="product__unit">/{product.unit}</span>
        </div>
      </div>
    </button>
  );
}
