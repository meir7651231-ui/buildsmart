type Props = {
  title: string;
  subtitle: string;
};

export function Placeholder({ title, subtitle }: Props) {
  return (
    <section class="placeholder">
      <div class="placeholder__badge">בקרוב</div>
      <h2 class="placeholder__title">{title}</h2>
      <p class="placeholder__subtitle">{subtitle}</p>
    </section>
  );
}
