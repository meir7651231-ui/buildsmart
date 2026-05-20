import { currentProducts } from '../store/app-store';
import { ProductCard } from './product-card';

export function ProductGrid() {
  const products = currentProducts.value;

  if (products.length === 0) {
    return (
      <div class="empty">
        <p class="empty__title">אין מוצרים בקטגוריה הזו עדיין</p>
        <p class="empty__sub">בחר קטגוריה אחרת או חפש לפי שם.</p>
      </div>
    );
  }

  return (
    <div class="products">
      {products.map((p) => (
        <ProductCard key={p.id} product={p} />
      ))}
    </div>
  );
}
